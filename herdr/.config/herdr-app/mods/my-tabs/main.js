import { View, div, svg, image } from "gpui-kit";
import { h_flex, ScrollHandle } from "gpui-base";
import { spaces, panes, run, openOverlay, theme, window, shared, layout, settings, nextCommand, checking } from "herdr";

function find(node, id) {
  if (node?.id === id) return node;
  for (const child of node?.children ?? []) {
    const found = find(child, id);
    if (found) return found;
  }
  return null;
}

// my-spaces' fixed spaces ({name, folder}) that `space` is one of, or null.
function fixedOf(space) {
  if (!space || space.machine) return null;
  return (shared("spaces.fixed") ?? []).find(f => f.name.toLowerCase() === space.name.toLowerCase()) ?? null;
}

// Drops what an agent puts before its title (a status glyph or spinner), as my-agents does.
const clean = (s) => (s ?? "").replace(/^[^\p{L}\p{N}\p{Ps}\p{Pi}]+/u, "").replace(/^\[ [!.] \] /, "").trim();
const base = (path) => (path ?? "").replace(/\/+$/, "").split("/").pop();

// An unnamed tab's label: its agent's title (Claude's session title), else the folder its
// terminal is in, else the program. A named tab (F2, or the handover's ticket key) keeps its name.
function label(tab) {
  if (tab.named) return tab.name;
  const own = panes().filter(p => p.tab === tab.id && p.terminal);
  const lead = own.find(p => p.program?.agent) ?? own.find(p => p.focused) ?? own[0];
  if (!lead) return tab.name;
  const title = clean(lead.title);
  const telling = lead.program?.agent && title && title !== lead.program.name && !/^[~/]/.test(title) && !title.includes("@");
  if (telling) return title;
  return base(lead.cwd) || lead.program?.name || tab.name;
}

export default class Tabs extends View {
  init(_props, cx) {
    this.pressed = null;
    this.scroll = ScrollHandle.new();
    this.panels = JSON.parse(localStorage.getItem("panels") ?? "{}");
    this.fresh = {}; // space -> the tab that replaced its closed last tab
    if (checking()) return;
    cx.spawn(async (cx) => {
      for (;;) {
        const command = await nextCommand();
        if (command === "close") this.close();
        else if (command === "new") this.open();
        cx.notify();
      }
    });
  }

  // A new tab in the shown space. A fixed space's tabs start in its own folder, not in
  // wherever its focused terminal has cd'd to, so the space doesn't drift.
  open() {
    const space = spaces().find(s => s.active), fixed = fixedOf(space);
    run("tab.new", fixed ? { space: space.id, folder: fixed.folder } : {});
  }

  // Spaces outlive their tabs: closing a space's only tab swaps it for a fresh
  // shell there, and only closing that fresh tab asks to close the space. A fixed
  // space never closes: its last fresh shell just stays.
  // `id`: the tab to close (default: the shown one).
  close(id) {
    const space = id ? spaces().find(s => s.tabs.some(c => c.id === id)) : spaces().find(s => s.active);
    const tab = space?.tabs.find(c => (id ? c.id === id : c.active));
    if (!tab || this.replacing) return;
    const fixed = fixedOf(space);
    if (space.tabs.length > 1) {
      run("tab.close", { id: tab.id });
      return;
    }
    if (this.fresh[space.id] === tab.id) {
      if (!fixed) run("tab.close", { id: tab.id });
      return;
    }
    this.replacing = { space: space.id, old: tab.id, until: Date.now() + 3000 };
    run("tab.new", fixed ? { space: space.id, folder: fixed.folder } : { space: space.id });
  }

  // The new tab shows up in spaces() a moment after tab.new: close the old one then.
  finishReplacing() {
    const r = this.replacing;
    if (!r) return;
    const made = spaces().find(s => s.id === r.space)?.tabs.find(c => c.id !== r.old);
    if (made) {
      this.fresh[r.space] = made.id;
      run("tab.close", { id: r.old });
    }
    if (made || Date.now() > r.until) this.replacing = null;
  }

  // The side panel is remembered per space: switching shows that space's choice
  // (closed if it never had one), and opening or closing it records it.
  syncPanel(space, panel, body, enabled) {
    if (!space || !panel) return;
    const now = panel.hidden ? null : body?.active ?? null;
    if (space.id !== this.space) {
      const first = this.space === undefined;
      this.space = space.id; this.pending = null;
      if (!(first && !(space.id in this.panels))) {
        const stored = this.panels[space.id] ?? null, want = enabled.includes(stored) ? stored : null;
        if (want !== now) {
          this.pending = { want, until: Date.now() + 1000 };
          if (want) { run("layout.select", { stack: "panel-body", child: want }); run("layout.show", { id: "panel" }); }
          else run("layout.hide", { id: "panel" });
          return;
        }
      }
    }
    // Until the restore lands (or something else won), the old state isn't a choice.
    if (this.pending) {
      if (this.pending.want !== now && Date.now() < this.pending.until) return;
      this.pending = null;
    }
    if (this.panels[space.id] === now) return;
    this.panels[space.id] = now;
    localStorage.setItem("panels", JSON.stringify(this.panels));
  }

  render() {
    this.finishReplacing();
    const t = theme();
    const space = spaces().find(p => p.active);
    const shown = space?.tabs ?? [];
    const active = shown.findIndex(tab => tab.active);
    const selected = shown[active]?.id;
    if (selected !== this.selected || active !== this.selectedIndex) {
      this.selected = selected;
      this.selectedIndex = active;
      if (active >= 0) this.scroll.scroll_to_item(active);
    }
    const stop = (_e, cx) => cx.stop_propagation();
    const button = (id, label, action) => div().id(id).size(26).flex_none().flex().items_center().justify_center().rounded(6).text_color(t.dim).hover(s => s.bg(t.hover).text_color(t.foreground))
      .on_mouse_down("left", stop).on_click(action).child(label);
    const item = (c, i) => {
      const program = panes().find(p => p.tab === c.id && p.program?.agent)?.program ?? panes().find(p => p.tab === c.id)?.program;
      const name = label(c);
      return h_flex().id(`tab-${c.id}`).h(29).px(10).gap(7).rounded(7).items_center().flex_none().text_size(12.8)
        // A rename or status dot on this or an earlier tab can push the active one out.
        .when(i <= active, el => el.on_size_change((_size, cx) => { this.scroll.scroll_to_item(active); cx.notify(); }))
        .border(1).border_color(c.active ? t.border : t.chrome).bg(c.active ? t.raised : t.chrome).text_color(c.active ? t.foreground : t.muted)
        .hover(s => s.bg(t.hover))
        .on_mouse_down("left", (e, cx) => { cx.stop_propagation(); this.pressed = i; if (e.click_count === 2) run("tab.rename", { id: c.id }); })
        .on_mouse_up("left", () => {
          const from = this.pressed; this.pressed = null;
          if (from !== null && from !== i) run("tab.move", { id: shown[from].id, index: space.tabs.findIndex(x => x.id === c.id) + 1 });
          else run("tab.select", { id: c.id });
        })
        .on_mouse_down("right", (_e, cx) => { cx.stop_propagation(); openOverlay({ mod: "menu", kind: "popup", width: 200, props: { tab: "tab", target: { id: c.id, space: space.id } } }); })
        .when(Boolean(program?.icon), el => el.child(program.tint ? svg(program.icon).size(14).text_color(t.muted) : image(program.icon).size(14)))
        .child(div().max_w(170).truncate().child(c.zoomed ? `${name} Z` : name))
        .when(c.status === "working", el => el.child(svg("mods/workspace-chrome/spinner.svg").size(12).flex_none().text_color(t.working).spin(900)))
        .when(c.status === "blocked" || c.status === "done", el => el.child(div().size(6).rounded(3).bg(t[c.status])))
        .when(c.active, el => el.child(div().id(`close-${c.id}`).text_color(t.dim).on_mouse_down("left", stop).on_click((_e, cx) => { cx.stop_propagation(); this.close(c.id); }).child(svg("mods/pane/close.svg").size(12))));
    };
    const root = layout(), sidebar = find(root, "sidebar"), w = window();
    // Old saved rails and a dragged-narrow sidebar can be smaller than the window buttons.
    const lightsPadding = w?.platform === "macos" && w.titlebar === "none" && !w.fullscreen && root?.traffic_lights
      ? Math.max(10, (root.traffic_lights[0] + 64) / settings().zoom - (sidebar?.hidden ? 0 : sidebar?.size?.px ?? 0))
      : 10;
    const panel = find(root, "panel"), body = find(root, "panel-body");
    const enabled = [...(shared("workspace.panels") ?? ["files", "changes"]), "tasks"];
    this.syncPanel(space, panel, body, enabled);
    const panelButton = (id, label, icon) => {
      const on = panel && !panel.hidden && body?.active === id;
      return h_flex().id(`panel-${id}`).h(26).px(8).gap(5).flex_none().items_center().rounded(6)
        .text_size(12).bg(on ? t.selected : t.chrome).text_color(on ? t.foreground : t.muted)
        .hover(s => s.bg(t.hover)).on_mouse_down("left", stop)
        .on_click(() => {
          if (on) run("layout.hide", { id: "panel" });
          else { run("layout.select", { stack: "panel-body", child: id }); run("layout.show", { id: "panel" }); }
        }).child(svg(icon).size(14)).child(label);
    };
    // Window buttons: the visible chip stays small, but each one's hit area spans
    // the bar's full height and the last reaches the window's right edge, so
    // flinging the pointer into the top-right corner lands on close.
    const windowButton = (id, icon, action, last) => {
      const hot = this.hovered === id;
      return h_flex().id(id).h_full().flex_none().items_center().pl(1.5).pr(last ? 10 : 1.5)
        .on_hover((on, cx) => { if (on) this.hovered = id; else if (this.hovered === id) this.hovered = null; cx.notify(); })
        .on_mouse_down("left", stop).on_click(action)
        .child(div().size(26).flex().items_center().justify_center().rounded(6)
          .text_color(hot ? t.foreground : t.dim).when(hot, el => el.bg(t.hover))
          .child(svg(`mods/my-tabs/${icon}.svg`).size(16)));
    };
    return h_flex().size_full().min_w(0).px(10).pl(lightsPadding).pr(w?.buttons ? 0 : 10).gap(3).items_center().bg(t.chrome).border_b(1).border_color(t.border)
      .on_mouse_up("left", () => { this.pressed = null; })
      .on_scroll_wheel(e => { if (Math.abs(e.delta.y) >= 1) run(e.delta.y > 0 ? "tab.prev" : "tab.next"); })
      .child(h_flex().id("tab-scroll").flex_1().min_w(0).h_full().items_center().gap(3).overflow_x_scrollbar().track_scroll(this.scroll)
        .on_size_change((_size, cx) => { if (active >= 0) { this.scroll.scroll_to_item(active); cx.notify(); } })
        .children(shown.map(item)))
      .child(button("tab-new", "+", () => openOverlay({ mod: "new-menu", kind: "popup", width: 250, height: 512 })))
      .when(enabled.includes("files"), el => el.child(panelButton("files", "Files", "mods/files/file.svg")))
      .when(enabled.includes("changes"), el => el.child(panelButton("changes", "Changes", "mods/changes/changes.svg")))
      .child(panelButton("tasks", "Tasks", "mods/tasks/tasks.svg"))
      .when(w?.buttons, el => el.child(h_flex().h_full().flex_none()
        .child(windowButton("minimize", "win-min", () => run("window.minimize")))
        .child(windowButton("maximize", w.maximized ? "win-restore" : "win-max", () => run("window.maximize")))
        .child(windowButton("close-window", "win-close", () => run("window.close"), true))));
  }
}
