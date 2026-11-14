// Tasks panel, next to Files and Changes. Two views:
// - Today: the day's ordered, numbered checklist (`task today`, one file per day, shared with the terminal).
// - All: `task ls --json`, in task's own order (needs you, in flight, waiting on others, to do).
// Both come from dotfiles: agents-config/claude-neocargo/task. Today rows show the live details
// from `task ls` when the ticket is listed there. The outlined row is task's NEXT: whatever needs
// you, else the first open item on today's list, else in flight, else the top to-do.
import { View, div, svg } from "gpui-kit";
import { v_flex, h_flex, InputState, Input } from "gpui-base";
import { exec, home, panes, run, theme } from "herdr";

// task ls asks Jira (one search) and GitLab (one GraphQL call) per run and takes ~6s.
const POLL_MS = 3 * 60 * 1000;
// task today only reads a local file: cheap, and picks up edits from the terminal and a new day.
const DAY_POLL_MS = 30 * 1000;
const MAX_SUGGESTIONS = 6;
// After herdr's agents change (one opens, closes or changes status), re-read the local state this
// long after: Claude's hook writes its state and a closed tab's Claude exits a moment later.
const AGENT_CHANGE_REFRESH_MS = [1000, 5000];

const ago = (secs) => {
  if (!secs) return "";
  const m = Math.floor((Date.now() / 1000 - secs) / 60);
  if (m < 1) return "now";
  if (m < 60) return `${m}m`;
  const h = Math.floor(m / 60);
  return h < 48 ? `${h}h` : `${Math.floor(h / 24)}d`;
};

const AGENT_STATES = new Set(["waiting", "permission", "working"]);
const asKey = (q) => { const m = /^\s*(?:ncp-?)?(\d+)\s*$/i.exec(q); return m ? `NCP-${m[1]}` : null; };

// Everything a task shows, for the All filter.
const haystack = (t) => [t.key, t.summary, t.status, t.group, ...(t.reasons ?? []),
  ...(t.mrs ?? []).map((m) => m.ref), ...(t.sessions ?? []).map((s) => s.prompt)].join(" ").toLowerCase();

export default class Tasks extends View {
  init(_props, cx) {
    this.tasks = null;
    this.day = null;
    this.error = null;
    this.loading = false;
    this.fetchedAt = 0;
    this.query = "";
    this.filter = "";
    this.heights = {}; // today row heights, for the drag placeholder
    this.width = 0;
    this.drag = null; // { key, dy, h, from }: the lifted today row
    this.slot = 0; // where it would drop, as an index into the list without it
    this.pointer = null; // pointer in panel coordinates while dragging
    try { this.view = localStorage.getItem("view") || "today"; } catch { this.view = "today"; }

    this.input = InputState.new({ placeholder: "Add to today: NCP number or title…" });
    this.input.on("change", (_e, cx) => { this.query = this.input.value(); cx.notify(); });
    this.input.on("submit", (_e, cx) => {
      const [first] = this.suggestions();
      if (first) this.add(first.key, cx);
    });
    this.filterInput = InputState.new({ placeholder: "Filter: key, title, status, MR…" });
    this.filterInput.on("change", (_e, cx) => { this.filter = this.filterInput.value(); cx.notify(); });

    this.refresh(cx);
    this.loadDay(cx);
    cx.timer.every(POLL_MS, (cx) => this.refresh(cx));
    cx.timer.every(DAY_POLL_MS, (cx) => { if (!this.drag) this.loadDay(cx); });
    cx.timer.every(60 * 1000, (cx) => cx.notify()); // keeps "3m ago" honest
    this.quickDue = [];
    cx.timer.every(1000, (cx) => {
      if (this.quickDue.length && Date.now() >= this.quickDue[0]) {
        this.quickDue.shift();
        this.refresh(cx, true);
      }
    });
  }

  task(args) {
    return exec(`${home()}/.local/bin/task`, args, { timeout: 90000 }).then((r) => {
      if (r.code !== 0) throw new Error((r.stderr || r.stdout).trim().split("\n").pop() || `exit ${r.code}`);
      return JSON.parse(r.stdout);
    });
  }

  // Full: asks Jira and GitLab (~6s, spinner). Quick: `--cached`, re-reads only the agent
  // sessions, checkouts and today's list (~0.1s), with Jira and GitLab from the last full run.
  refresh(cx, quick = false) {
    if (this.loading || (quick && this.quick)) return;
    if (quick) this.quick = true; else { this.loading = true; cx.notify(); }
    cx.spawn(async (cx) => {
      try {
        this.tasks = await this.task(["ls", "--json", ...(quick ? ["--cached"] : [])]);
        if (!quick) this.fetchedAt = Date.now();
        this.error = null;
      } catch (e) {
        this.error = String(e?.message ?? e);
      } finally {
        if (quick) this.quick = false; else this.loading = false;
        cx.notify();
      }
    });
  }

  // Render runs whenever herdr's live data changes; this notices when that was the agents.
  watchAgents() {
    const sig = panes().filter((p) => p.status).map((p) => `${p.pane}:${p.status}:${p.cwd}:${p.branch}`).sort().join("|");
    if (this.agentSig !== undefined && sig !== this.agentSig) this.quickDue = AGENT_CHANGE_REFRESH_MS.map((ms) => Date.now() + ms);
    this.agentSig = sig;
  }

  // `task today [action keys...] --json`; the answer is the day's list after the change.
  // The day's list changes what task ls calls NEXT, so that follows (quietly, in the background).
  loadDay(cx, action = []) {
    cx.spawn(async (cx) => {
      try {
        this.day = await this.task(["today", ...action, "--json"]);
      } catch (e) {
        this.error = String(e?.message ?? e);
      }
      cx.notify();
      if (action.length) this.refresh(cx, true); // NEXT depends on the list
    });
  }

  // Changes show at once; task's answer then replaces them.
  change(cx, action, local) {
    if (this.day) local(this.day.items);
    cx.notify();
    this.loadDay(cx, action);
  }

  add(key, cx) {
    this.input.set_value("");
    this.query = "";
    const known = this.tasks?.find((t) => t.key === key);
    this.change(cx, ["add", key], (items) => {
      if (!items.some((i) => i.key === key)) items.push({ key, summary: known?.summary ?? "", done: false, url: known?.url });
    });
  }

  remove(key, cx) { this.change(cx, ["rm", key], (items) => items.splice(items.findIndex((i) => i.key === key), 1)); }

  toggle(item, cx) {
    this.change(cx, [item.done ? "uncheck" : "check", item.key], () => { item.done = !item.done; });
  }

  // --- drag and drop on Today ---

  lift(item, from, e, cx) {
    // Where in the row it was grabbed: the grip's offset in the row (padding) plus in the grip.
    this.drag = { key: item.key, from, h: this.heights[item.key] ?? 64, dy: 7 + (e.local_position?.y ?? 6) };
    this.slot = from;
    this.pointer = null;
    cx.notify();
  }

  // Over a row of the list without the lifted one: once the pointer passes its middle, the
  // placeholder moves to that side of it. Rows shift by the placeholder's height then, and the
  // pointer ends on the placeholder or the row's same half, so it never flips back and forth.
  hoverRow(r, e, cx) {
    if (!this.drag) return;
    const lower = e.local_position.y > e.bounds.height / 2;
    const slot = this.slot <= r ? (lower ? r + 1 : this.slot) : (lower ? this.slot : r);
    if (slot !== this.slot) { this.slot = slot; cx.notify(); }
  }

  drop(cx) {
    const drag = this.drag;
    this.drag = this.pointer = null;
    if (!drag || !this.day || this.slot === drag.from) { cx.notify(); return; }
    const slot = this.slot;
    this.change(cx, ["move", drag.key, String(slot + 1)], (items) => {
      const [moved] = items.splice(drag.from, 1);
      items.splice(slot, 0, moved);
    });
  }

  setView(view, cx) {
    this.view = view;
    try { localStorage.setItem("view", view); } catch {}
    cx.notify();
  }

  todayIndex(key) { return this.day?.items.findIndex((i) => i.key === key) ?? -1; }

  suggestions() {
    const q = this.query.trim().toLowerCase();
    if (!q) return [];
    const out = (this.tasks ?? []).filter((t) => t.key.startsWith("NCP-") && this.todayIndex(t.key) < 0
      && (t.key.toLowerCase().includes(q) || t.key.slice(4).startsWith(q) || (t.summary ?? "").toLowerCase().includes(q)))
      .slice(0, MAX_SUGGESTIONS);
    const typed = asKey(q);
    if (typed && this.todayIndex(typed) < 0 && !out.some((t) => t.key === typed)) out.unshift({ key: typed, summary: "", typed: true });
    return out;
  }

  // Which herdr pane runs each task's agent session: same folder and branch, and only
  // when the match is one-to-one (herdr doesn't know Claude's session ids).
  agentPanes(tasks) {
    const live = panes().filter((p) => p.status && p.cwd);
    const cands = new Map(), claims = new Map();
    for (const task of tasks) {
      const set = new Set();
      for (const s of task.sessions ?? []) {
        if (!AGENT_STATES.has(s.state)) continue;
        for (const p of live) {
          if (p.cwd === s.cwd && (!p.branch || !s.branch || p.branch === s.branch)) set.add(p.pane);
        }
      }
      cands.set(task.key, set);
      for (const pane of set) claims.set(pane, (claims.get(pane) ?? 0) + 1);
    }
    const out = new Map();
    for (const [key, set] of cands) {
      const [pane] = set;
      if (set.size === 1 && claims.get(pane) === 1) out.set(key, pane);
    }
    return out;
  }

  reasonColor(t, task) {
    if (task.group === "Needs you") return t.blocked;
    if (task.group === "In flight") return t.working;
    return t.dim;
  }

  link(t, id, text, url, color) {
    return div().id(id).flex_none().cursor_pointer().text_color(color ?? t.accent).hover((s) => s.underline())
      .on_click((_e, cx) => { cx.stop_propagation(); if (url) cx.open_url(url); })
      .child(text);
  }

  button(t, id, label, tip, onClick) {
    return div().id(id).flex_none().cursor_pointer().px(6).rounded(4).text_color(t.dim)
      .hover((s) => s.bg(t.hover).text_color(t.foreground))
      .tooltip(tip)
      .on_mouse_down("left", (_e, cx) => cx.stop_propagation())
      .on_click((_e, cx) => { cx.stop_propagation(); onClick(cx); })
      .child(label);
  }

  nextTag(t, task) {
    return div().id(`next-${task.key}`).flex_none().px(5).rounded(4).bg(t.accent).text_color(t.accent_foreground)
      .text_size(10.5).font_semibold().tooltip(`Next: ${task.next}`).child("NEXT");
  }

  // The lines of one task: key, status, age, agent; title; reasons and MRs.
  details(t, task, pane, { done = false, extra = [] } = {}) {
    const isTicket = task.key.startsWith("NCP-");
    const title = isTicket ? task.summary : (task.sessions?.[0]?.prompt ?? task.key);
    const mrs = task.mrs ?? [];
    const pipe = (m) => m.pipeline === "failed" ? t.blocked : m.pipeline === "success" ? t.ansi2 : m.pipeline ? t.working : t.dim;
    return v_flex().flex_1().min_w(0).gap(3)
      .child(h_flex().gap(8).items_center().text_size(11.5)
        .child(isTicket
          ? this.link(t, `key-${task.key}`, task.key, task.url, done ? t.dim : t.accent)
          : div().flex_none().text_color(t.muted).child(task.key.replace(/^session:/, "")))
        .when(Boolean(task.status), (el) => el.child(div().flex_none().text_color(t.dim).child(task.status)))
        .when(Boolean(task.next) && !done, (el) => el.child(this.nextTag(t, task)))
        .child(div().flex_1())
        .when(Boolean(task.since) && !done, (el) => el.child(div().flex_none().text_color(t.dim).child(ago(task.since))))
        .when(Boolean(pane) && !done, (el) => el.child(
          div().id(`agent-${task.key}`).flex_none().cursor_pointer().px(6).rounded(4).bg(t.selected).text_color(t.foreground)
            .hover((s) => s.bg(t.accent).text_color(t.accent_foreground))
            .tooltip("Go to the agent")
            .on_mouse_down("left", (_e, cx) => cx.stop_propagation())
            .on_click((_e, cx) => { cx.stop_propagation(); run("pane.focus", { pane }); })
            .child("agent →")))
        .children(extra))
      .child(div().text_size(12.8).text_color(done ? t.dim : t.foreground).when(done, (el) => el.line_through())
        .child(title || "(no summary)"))
      .when(!done && ((task.reasons ?? []).length > 0 || mrs.length > 0), (el) => el.child(
        h_flex().gap(8).items_center().text_size(11.5).flex_wrap()
          .child(div().text_color(this.reasonColor(t, task)).child((task.reasons ?? []).join(" · ")))
          .children(mrs.map((m) => h_flex().gap(4).items_center()
            .child(div().size(6).rounded(3).bg(pipe(m)))
            .child(this.link(t, `mr-${task.key}-${m.ref}`, m.ref, m.url, t.muted))))));
  }

  // --- views ---

  header(t) {
    const tab = (id, label, count) => {
      const on = this.view === id;
      return h_flex().id(`view-${id}`).h(24).px(8).gap(5).items_center().rounded(6).cursor_pointer()
        .bg(on ? t.selected : t.surface).text_color(on ? t.foreground : t.muted).hover((s) => s.bg(t.hover))
        .on_click((_e, cx) => this.setView(id, cx))
        .child(label).child(div().text_color(t.dim).child(count));
    };
    const items = this.day?.items ?? [];
    const updated = ago(this.fetchedAt / 1000);
    return h_flex().h(40).px(8).gap(4).items_center().flex_none().border_b(1).border_color(t.border).text_size(12.5)
      .child(tab("today", "Today", items.length ? `${items.filter((i) => i.done).length}/${items.length}` : ""))
      .child(tab("all", "All", this.tasks ? String(this.tasks.length) : ""))
      .child(div().flex_1())
      .when(Boolean(this.fetchedAt), (el) => el.child(div().text_size(11.5).text_color(t.dim)
        .child(updated === "now" ? "updated now" : `updated ${updated} ago`)))
      .child(div().id("refresh").cursor_pointer().size(24).flex().items_center().justify_center().rounded(5).text_color(t.dim)
        .hover((s) => s.bg(t.hover).text_color(t.foreground))
        .tooltip("Refresh (task ls)")
        .on_click((_e, cx) => { this.refresh(cx); this.loadDay(cx); })
        .child(this.loading ? svg("mods/workspace-chrome/spinner.svg").size(13).spin(900) : "↻"));
  }

  note(t, text, color) { return div().px(6).py(4).text_size(12).text_color(color ?? t.dim).child(text); }

  field(t, id, state, active) {
    return div().id(id).mx(2).mb(6).h(32).px(10).flex().items_center().rounded(8).border_1()
      .border_color(active ? t.accent : t.border).cursor_text()
      .child(Input.new(state).w_full().h_full().text_size(12.5).text_color(t.foreground));
  }

  checkbox(t, item, onClick) {
    const box = onClick ? div().id(`check-${item.key}`) : div();
    return box.flex_none().size(16).mt(1).rounded(4).border_1()
      .flex().items_center().justify_center()
      .border_color(item.done ? t.ansi2 : t.input).bg(item.done ? t.ansi2 : t.surface)
      .when(Boolean(onClick), (el) => el.cursor_pointer()
        .on_mouse_down("left", (_e, cx) => cx.stop_propagation())
        .on_click((_e, cx) => onClick(cx)))
      .when(item.done, (el) => el.child(svg("mods/tasks/check.svg").size(12).text_color(t.background)));
  }

  number(t, n, done) {
    return div().flex_none().w(18).pt(1).text_size(12).text_color(done ? t.dim : t.muted).child(`${n}.`);
  }

  todayView(t, panesByKey) {
    const out = [];
    const day = this.day;
    out.push(this.field(t, "add", this.input, Boolean(this.query)));
    const sugg = this.suggestions();
    if (sugg.length) {
      out.push(v_flex().mx(2).mb(6).p(4).gap(1).rounded(8).bg(t.raised).border_1().border_color(t.border).children(
        sugg.map((s, i) => h_flex().id(`sugg-${s.key}`).px(8).py(5).gap(8).rounded(5).items_center().cursor_pointer()
          .when(i === 0, (el) => el.bg(t.hover)).hover((st) => st.bg(t.hover))
          .on_click((_e, cx) => this.add(s.key, cx))
          .child(div().flex_none().text_size(11.5).text_color(t.accent).child(s.key))
          .child(div().flex_1().min_w(0).truncate().text_size(12.5).text_color(s.typed ? t.dim : t.foreground)
            .child(s.typed ? "add by number" : s.summary))
          .when(i === 0, (el) => el.child(div().flex_none().text_size(11).text_color(t.dim).child("↵"))))));
    }
    if (!day) { out.push(this.note(t, "Loading today…")); return out; }
    if (day.carry?.length) {
      out.push(h_flex().id("carry").mx(2).mb(4).px(10).py(7).gap(8).items_center().rounded(7).cursor_pointer()
        .border_1().border_color(t.border).text_size(12.5).text_color(t.muted).hover((s) => s.bg(t.hover).text_color(t.foreground))
        .on_click((_e, cx) => this.loadDay(cx, ["carry"]))
        .child(div().text_color(t.accent).child("↻"))
        .child(`Carry over ${day.carry.length} open from ${day.carry_from}`)
        .tooltip(day.carry.join(", ")));
    }
    if (!day.items.length) {
      out.push(this.note(t, "Nothing planned yet. Search above, or use + today in All."));
      return out;
    }
    const byKey = new Map((this.tasks ?? []).map((x) => [x.key, x]));
    const drag = this.drag;
    // While dragging, the lifted row leaves the list and a placeholder of its height takes the slot.
    const rest = drag ? day.items.filter((i) => i.key !== drag.key) : day.items;
    const placeholder = () => div().h(drag.h).my(1).rounded(7).border_1().border_dashed().border_color(t.input);
    rest.forEach((item, r) => {
      if (drag && r === this.slot) out.push(placeholder());
      const task = { ...item, ...(byKey.get(item.key) ?? {}) };
      const n = drag ? (r < this.slot ? r : r + 1) + 1 : r + 1; // numbers as they will be after the drop
      out.push(h_flex().id(`today-${item.key}`).px(4).py(6).gap(4).items_start().rounded(7)
        .when(!drag, (el) => el.hover((s) => s.bg(t.hover)))
        .on_size_change((size) => { this.heights[item.key] = size.height; })
        .on_mouse_move((e, cx) => this.hoverRow(r, e, cx))
        .child(div().id(`grip-${item.key}`).flex_none().w(14).pt(1).text_size(13).text_color(t.dim).cursor_grab()
          .hover((s) => s.text_color(t.foreground))
          .tooltip("Drag to reorder")
          .on_mouse_down("left", (e, cx) => { cx.stop_propagation(); this.lift(item, r, e, cx); })
          .child("⠿"))
        .child(this.number(t, n, item.done))
        .child(this.checkbox(t, item, (cx) => this.toggle(item, cx)))
        .child(div().w(6).flex_none())
        .child(this.details(t, task, panesByKey.get(item.key), {
          done: item.done,
          extra: [this.button(t, `rm-${item.key}`, "✕", "Remove from today", (cx) => this.remove(item.key, cx))],
        })));
    });
    if (drag && this.slot >= rest.length) out.push(placeholder());
    return out;
  }

  // The lifted row, following the pointer above the list. Nothing in it reacts to the mouse, so
  // the rows underneath keep getting the pointer.
  lifted(t) {
    const drag = this.drag;
    if (!drag || !this.pointer) return null;
    const item = this.day?.items.find((i) => i.key === drag.key);
    if (!item) return null;
    const task = { ...item, ...((this.tasks ?? []).find((x) => x.key === item.key) ?? {}) };
    return h_flex().absolute().left(10).top(this.pointer.y - drag.dy).w(Math.max(0, this.width - 20)).h(drag.h)
      .px(4).py(6).gap(4).items_start().rounded(7).bg(t.raised).border_1().border_color(t.accent).shadow_lg().opacity(0.95)
      .child(div().flex_none().w(14).pt(1).text_size(13).text_color(t.foreground).child("⠿"))
      .child(this.number(t, this.slot + 1, item.done))
      .child(this.checkbox(t, item, null))
      .child(div().w(6).flex_none())
      .child(v_flex().flex_1().min_w(0).gap(3)
        .child(div().text_size(11.5).text_color(t.accent).child(item.key))
        .child(div().text_size(12.8).text_color(t.foreground).child(task.summary || "(no summary)")));
  }

  allView(t, panesByKey) {
    const out = [this.field(t, "filter", this.filterInput, Boolean(this.filter))];
    if (!this.tasks) {
      if (this.loading) out.push(this.note(t, "Asking Jira and GitLab…"));
      return out;
    }
    const q = this.filter.trim().toLowerCase();
    const shown = q ? this.tasks.filter((x) => haystack(x).includes(q)) : this.tasks;
    if (!shown.length) { out.push(this.note(t, q ? "No task matches." : "Nothing in flight.")); return out; }
    let group = null;
    shown.forEach((task, i) => {
      if (task.group !== group) {
        group = task.group;
        const n = shown.filter((x) => x.group === group).length;
        out.push(h_flex().px(6).pt(i === 0 ? 2 : 12).pb(2).gap(6).text_size(11).text_color(t.muted).font_semibold()
          .child(group.toUpperCase()).child(div().text_color(t.dim).child(String(n))));
      }
      const ticket = task.key.startsWith("NCP-");
      const at = this.todayIndex(task.key);
      const item = at >= 0 ? this.day.items[at] : null;
      // Planned: its place on today's list, so the order of the day shows here too.
      const extra = !ticket ? [] : item
        ? [div().id(`planned-${task.key}`).flex_none().px(6).rounded(4).text_size(11).font_semibold()
            .bg(item.done ? t.surface : t.selected).text_color(item.done ? t.dim : t.foreground)
            .tooltip(item.done ? "Done today" : `#${at + 1} on today's list`)
            .child(item.done ? "today ✓" : `today #${at + 1}`)]
        : [this.button(t, `plan-${task.key}`, "+ today", "Add to today's list", (cx) => this.add(task.key, cx))];
      out.push(div().id(`task-${task.key}`).px(10).py(7).rounded(7)
        .when(Boolean(task.next), (el) => el.bg(t.raised).border(1).border_color(t.accent))
        .hover((s) => s.bg(t.hover))
        .child(this.details(t, task, panesByKey.get(task.key), { extra })));
    });
    return out;
  }

  render() {
    this.watchAgents();
    const t = theme();
    const panesByKey = this.agentPanes(this.tasks ?? []);
    const items = [];
    if (this.error) items.push(this.note(t, `task failed: ${this.error}`, t.blocked));
    items.push(...(this.view === "today" ? this.todayView(t, panesByKey) : this.allView(t, panesByKey)));
    const lifted = this.view === "today" ? this.lifted(t) : null;
    return v_flex().id("tasks-root").relative().size_full().bg(t.surface)
      .on_size_change((size, cx) => { if (this.width !== size.width) { this.width = size.width; cx.notify(); } })
      .when(Boolean(this.drag), (el) => el.cursor_grabbing())
      .on_mouse_move((e, cx) => { if (this.drag) { this.pointer = e.local_position; cx.notify(); } })
      // Releasing anywhere in the panel drops into the placeholder's slot.
      .on_mouse_up("left", (_e, cx) => { if (this.drag) this.drop(cx); })
      .child(this.header(t))
      .child(v_flex().id("task-list").flex_1().min_h(0).overflow_y_scrollbar().p(8).gap(this.view === "today" ? 0 : 2).children(items))
      .when(Boolean(lifted), (el) => el.child(lifted));
  }
}
