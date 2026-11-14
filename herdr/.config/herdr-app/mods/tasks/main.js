// Tasks panel, next to Files and Changes. Two views:
// - Today: the day's ordered, numbered checklist (`task today`, one file per day, shared with
//   the terminal).
// - All: `task ls --json`, in task's own order (needs you, in flight, waiting on others, to do).
// Both come from dotfiles: agents-config/claude-neocargo/task. Today rows show the live details
// from `task ls` when the ticket is listed there. The outlined row is task's NEXT: whatever needs
// you, else the first open item on today's list, else in flight, else the top to-do.
//
// This file holds the state and the actions; the rest only draws:
//   today.js, all.js   the two views
//   task-row.js        one task's lines, shared by both
//   kit.js             buttons, links, checkbox, …
import { View, div, svg } from "gpui-kit";
import { v_flex, h_flex, InputState } from "gpui-base";
import { exec, home, panes, theme } from "herdr";
import { ago, compact, isTicket, note } from "./kit.js";
import { todayView, liftedRow } from "./today.js";
import { allView } from "./all.js";

// task ls asks Jira (one search) and GitLab (one GraphQL call) per run and takes ~6s.
const POLL_MS = 3 * 60 * 1000;
// task today only reads a local file: cheap, and picks up edits from the terminal and a new day.
const DAY_POLL_MS = 30 * 1000;
const MAX_SUGGESTIONS = 6;
// After herdr's agents change (one opens, closes or changes status), re-read the local state this
// long after: Claude's hook writes its state and a closed tab's Claude exits a moment later.
const AGENT_CHANGE_REFRESH_MS = [1000, 5000];

// The session states of a running agent.
const AGENT_STATES = new Set(["waiting", "permission", "working"]);

// "1234", "ncp1234" or "NCP-1234" as a ticket key; null for anything else.
function asKey(text) {
  const m = /^\s*(?:ncp-?)?(\d+)\s*$/i.exec(text);
  return m ? `NCP-${m[1]}` : null;
}

export default class Tasks extends View {
  init(_props, cx) {
    this.tasks = null; // `task ls --json`
    this.byKey = new Map(); // the same, by key
    this.day = null; // `task today --json`
    this.error = null;
    this.loading = false; // a full refresh is running
    this.quick = false; // a quick (--cached) refresh is running
    this.fetchedAt = 0;
    this.agentSig = undefined; // herdr's agents as last rendered, see watchAgents
    this.quickDue = []; // when the quick refreshes after an agent change are due
    this.query = ""; // Today's add field
    this.filter = ""; // All's filter field
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
    this.filterInput.on("change", (_e, cx) => {
      this.filter = this.filterInput.value();
      cx.notify();
    });

    this.refresh(cx);
    this.loadDay(cx);
    cx.timer.every(POLL_MS, (cx) => this.refresh(cx));
    cx.timer.every(DAY_POLL_MS, (cx) => { if (!this.drag) this.loadDay(cx); });
    cx.timer.every(60 * 1000, (cx) => cx.notify()); // keeps "3m ago" honest
    // watchAgents runs in render, which has no cx to start a timer with: it leaves times here.
    cx.timer.every(1000, (cx) => {
      if (this.quickDue.length && Date.now() >= this.quickDue[0]) {
        this.quickDue.shift();
        this.refresh(cx, true);
      }
    });
  }

  // --- talking to task ---

  async task(args) {
    const r = await exec(`${home()}/.local/bin/task`, args, { timeout: 90000 });
    if (r.code !== 0) {
      throw new Error((r.stderr || r.stdout).trim().split("\n").pop() || `exit ${r.code}`);
    }
    return JSON.parse(r.stdout);
  }

  // Full: asks Jira and GitLab (~6s, spinner). Quick: `--cached`, re-reads only the agent
  // sessions, checkouts and today's list (~0.1s), with Jira and GitLab from the last full run.
  refresh(cx, quick = false) {
    const busy = quick ? "quick" : "loading";
    if (this.loading || this[busy]) return;
    this[busy] = true;
    if (!quick) cx.notify();
    cx.spawn(async (cx) => {
      try {
        this.tasks = await this.task(["ls", "--json", ...(quick ? ["--cached"] : [])]);
        this.byKey = new Map(this.tasks.map((task) => [task.key, task]));
        if (!quick) this.fetchedAt = Date.now();
        this.error = null;
      } catch (e) {
        this.error = String(e?.message ?? e);
      } finally {
        this[busy] = false;
        cx.notify();
      }
    });
  }

  // Render runs whenever herdr's live data changes; this notices when that was the agents.
  watchAgents() {
    const sig = panes()
      .filter((p) => p.status)
      .map((p) => `${p.pane}:${p.status}:${p.cwd}:${p.branch}`)
      .sort()
      .join("|");
    if (this.agentSig !== undefined && sig !== this.agentSig) {
      this.quickDue = AGENT_CHANGE_REFRESH_MS.map((ms) => Date.now() + ms);
    }
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
      if (action.length) this.refresh(cx, true);
    });
  }

  // --- today's list ---

  // Changes show at once (`local` edits the items in place); task's answer then replaces them.
  change(cx, action, local) {
    if (this.day) local(this.day.items);
    cx.notify();
    this.loadDay(cx, action);
  }

  add(key, cx) {
    this.input.set_value("");
    this.query = "";
    const known = this.byKey.get(key);
    this.change(cx, ["add", key], (items) => {
      if (items.some((i) => i.key === key)) return;
      items.push({ key, summary: known?.summary ?? "", done: false, url: known?.url });
    });
  }

  remove(key, cx) {
    this.change(cx, ["rm", key], (items) => {
      const at = items.findIndex((i) => i.key === key);
      if (at >= 0) items.splice(at, 1);
    });
  }

  toggle(item, cx) {
    const action = item.done ? "uncheck" : "check";
    this.change(cx, [action, item.key], () => { item.done = !item.done; });
  }

  todayIndex(key) { return this.day?.items.findIndex((i) => i.key === key) ?? -1; }

  /** A today item with what `task ls` knows about its ticket (status, reasons, MRs, …). */
  withLiveDetails(item) { return { ...item, ...this.byKey.get(item.key) }; }

  /** What the add field offers: listed tickets matching by key or title, and a typed number. */
  suggestions() {
    const q = this.query.trim().toLowerCase();
    if (!q) return [];
    const unplanned = (key) => this.todayIndex(key) < 0;
    const matches = (task) =>
      task.key.toLowerCase().includes(q) || (task.summary ?? "").toLowerCase().includes(q);
    const out = (this.tasks ?? [])
      .filter((task) => isTicket(task.key) && unplanned(task.key) && matches(task))
      .slice(0, MAX_SUGGESTIONS);
    const typed = asKey(q);
    if (typed && unplanned(typed) && !out.some((task) => task.key === typed)) {
      out.unshift({ key: typed, summary: "", typed: true });
    }
    return out;
  }

  // --- drag and drop on Today ---

  lift(item, from, e, cx) {
    // Where in the row it was grabbed: the grip's offset in the row (padding) plus in the grip.
    const dy = 7 + (e.local_position?.y ?? 6);
    this.drag = { key: item.key, from, h: this.heights[item.key] ?? 64, dy };
    this.slot = from;
    this.pointer = null;
    cx.notify();
  }

  // Over row `r` of the list without the lifted one: once the pointer passes its middle, the
  // placeholder moves to that side of it. Rows shift by the placeholder's height then, and the
  // pointer ends on the placeholder or the row's same half, so it never flips back and forth.
  hoverRow(r, e, cx) {
    if (!this.drag) return;
    const lowerHalf = e.local_position.y > e.bounds.height / 2;
    let slot = this.slot;
    if (this.slot <= r && lowerHalf) slot = r + 1; // placeholder above the row: move below it
    if (this.slot > r && !lowerHalf) slot = r; // placeholder below the row: move above it
    if (slot !== this.slot) { this.slot = slot; cx.notify(); }
  }

  drop(cx) {
    const { drag, slot } = this;
    this.drag = this.pointer = null;
    if (!drag || !this.day || slot === drag.from) { cx.notify(); return; }
    this.change(cx, ["move", drag.key, String(slot + 1)], (items) => {
      const [moved] = items.splice(drag.from, 1);
      items.splice(slot, 0, moved);
    });
  }

  // --- agents ---

  // Which herdr pane runs each task's agent session: same folder and branch, and only
  // when the match is one-to-one (herdr doesn't know Claude's session ids).
  agentPanes() {
    const live = panes().filter((p) => p.status && p.cwd);
    const runs = (p, s) => p.cwd === s.cwd && (!p.branch || !s.branch || p.branch === s.branch);
    const candidates = new Map(); // task key -> panes that could be its agent
    const claims = new Map(); // pane -> how many tasks it could belong to
    for (const task of this.tasks ?? []) {
      const sessions = (task.sessions ?? []).filter((s) => AGENT_STATES.has(s.state));
      const found = new Set(
        live.filter((p) => sessions.some((s) => runs(p, s))).map((p) => p.pane),
      );
      candidates.set(task.key, found);
      for (const pane of found) claims.set(pane, (claims.get(pane) ?? 0) + 1);
    }
    const out = new Map();
    for (const [key, found] of candidates) {
      const [pane] = found;
      if (found.size === 1 && claims.get(pane) === 1) out.set(key, pane);
    }
    return out;
  }

  // --- drawing ---

  setView(view, cx) {
    this.view = view;
    try { localStorage.setItem("view", view); } catch {}
    cx.notify();
  }

  viewTab(t, id, label, count) {
    const on = this.view === id;
    return h_flex().id(`view-${id}`)
      .h(24).px(8).gap(5).items_center().rounded(6).cursor_pointer()
      .bg(on ? t.selected : t.surface).text_color(on ? t.foreground : t.muted)
      .hover((s) => s.bg(t.hover))
      .on_click((_e, cx) => this.setView(id, cx))
      .child(label)
      .child(div().text_color(t.dim).child(count));
  }

  refreshButton(t) {
    const spinner = () => svg("mods/workspace-chrome/spinner.svg").size(13).spin(900);
    return div().id("refresh")
      .size(24).flex().items_center().justify_center().rounded(5).cursor_pointer()
      .text_color(t.dim)
      .hover((s) => s.bg(t.hover).text_color(t.foreground))
      .tooltip("Refresh (task ls)")
      .on_click((_e, cx) => { this.refresh(cx); this.loadDay(cx); })
      .child(this.loading ? spinner() : "↻");
  }

  header(t) {
    const items = this.day?.items ?? [];
    const progress = items.length ? `${items.filter((i) => i.done).length}/${items.length}` : "";
    const age = ago(this.fetchedAt / 1000);
    const updated = div().text_size(11.5).text_color(t.dim)
      .child(age === "now" ? "updated now" : `updated ${age} ago`);
    return h_flex()
      .h(40).px(8).gap(4).items_center().flex_none()
      .border_b(1).border_color(t.border).text_size(12.5)
      .children(compact([
        this.viewTab(t, "today", "Today", progress),
        this.viewTab(t, "all", "All", this.tasks ? String(this.tasks.length) : ""),
        div().flex_1(),
        this.fetchedAt && updated,
        this.refreshButton(t),
      ]));
  }

  render() {
    this.watchAgents();
    const t = theme();
    const today = this.view === "today";
    const agentPanes = this.agentPanes();
    const rows = today ? todayView(this, t, agentPanes) : allView(this, t, agentPanes);
    const error = this.error && note(t, `task failed: ${this.error}`, t.blocked);
    return v_flex().id("tasks-root")
      .relative().size_full().bg(t.surface)
      .on_size_change((size, cx) => {
        if (this.width !== size.width) { this.width = size.width; cx.notify(); }
      })
      // The drag is tracked on the whole panel: releasing anywhere drops into the placeholder.
      .when(Boolean(this.drag), (el) => el.cursor_grabbing())
      .on_mouse_move((e, cx) => {
        if (this.drag) { this.pointer = e.local_position; cx.notify(); }
      })
      .on_mouse_up("left", (_e, cx) => { if (this.drag) this.drop(cx); })
      .child(this.header(t))
      .child(v_flex().id("task-list")
        .flex_1().min_h(0).overflow_y_scrollbar().p(8).gap(today ? 0 : 2)
        .children(compact([error, ...rows])))
      .children(compact([today && liftedRow(this, t)]));
  }
}
