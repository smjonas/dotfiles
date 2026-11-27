// Hands a to-do ticket to a new Claude agent. Opened by the Tasks panel on a right-click, twice:
// - as a popup with props { menu: true, task }: the one-item context menu;
// - as a dialog with props { task }: pick the project, edit the first message, start.
// `task` is { key, summary, type } from `task ls`.
//
// The agent is claude-neocargo (Claude in the NeoCargo container; `cc` is the shell's alias for
// it, and herdr's launcher doesn't expand aliases), in a new tab. It works in a git worktree of
// its own, <project>/.claude/worktrees/<key> on a branch named <key>, so several agents can
// work on one project at once. The dialog makes the worktree before it starts the agent.
import { View, div, svg } from "gpui-kit";
import { v_flex, h_flex, Input, InputState, Textarea, TextareaState } from "gpui-base";
import { closeOverlay, exec, home, openOverlay, props, readTextFile, run, spaces, theme, writeTextFile } from "herdr";

const MOD = "task-handover";
const AGENT = ["claude-neocargo"];
// The folder claude-neocargo mounts; each project is a git checkout directly inside it.
const ROOT = `${home()}/Desktop/NeoCargo`;
// Shown first, in this order, under the name they go by.
const PINNED = [
  { alias: "neobase", dir: "consignment-service" },
  { alias: "neomatch", dir: "neomatch-service" },
  { alias: "matcher", dir: "matcher-service" },
  { alias: "tcc", dir: "timocom-addon" },
];
// The branch work starts from: the first of these the project's remote has.
const BASE_BRANCHES = ["dev", "main", "master"];
const PLAN = "Plan the changes first.";

const FETCH_TIMEOUT_MS = 60 * 1000;

// Where Claude Code keeps its own worktrees too, inside the project.
const WORKTREES = ".claude/worktrees";
const worktreeDir = (dir, key) => `${dir}/${WORKTREES}/${key}`;
/** A checkout's folder as the dialog names it: from the project folder on. */
const short = (path) => (path.startsWith(`${ROOT}/`) ? path.slice(ROOT.length + 1) : path);

/** The first message: what to do, and where the agent finds itself (`state`: projectState). */
function instruction(task, state) {
  const please = `Please ${task.type === "Bug" ? "fix" : "implement"} ${task.key}.`;
  if (state?.existing) {
    return `${please} You are in its existing checkout, on branch ${state.existing.branch || "(detached)"}.`;
  }
  if (state?.branchExists) {
    return `${please} You are in a new git worktree on the existing branch ${task.key}.`;
  }
  return `${please} You are in a new git worktree on branch ${task.key}, ` +
    `created from the latest ${state?.base ?? BASE_BRANCHES[0]} branch.`;
}

async function git(dir, args) {
  const r = await exec("git", args, { cwd: `${ROOT}/${dir}` });
  return r.code === 0 ? r.stdout.trim() : "";
}

/** Like git(), for the commands that change something: a failure throws git's last line. */
async function mustGit(dir, args, timeout) {
  const r = await exec("git", args, { cwd: `${ROOT}/${dir}`, ...(timeout ? { timeout } : {}) });
  if (r.code !== 0) throw new Error((r.stderr || r.stdout).trim().split("\n").pop() || `git ${args[0]} failed`);
}

/** The project folders: the pinned ones first, then the rest by name. Linked worktrees
 *  (`.git` is a file there) are checkouts of a project, not projects. */
async function listProjects() {
  const r = await exec("find", [ROOT, "-mindepth", "2", "-maxdepth", "2", "-name", ".git", "-type", "d"]);
  const dirs = new Set(r.stdout.split("\n").filter(Boolean).map((p) => p.split("/").at(-2)));
  const pinned = PINNED.filter((p) => dirs.has(p.dir));
  const rest = [...dirs].filter((dir) => !pinned.some((p) => p.dir === dir)).sort();
  return [...pinned, ...rest.map((dir) => ({ alias: null, dir }))];
}

/** The project's checkouts (`git worktree list`): [{ path, branch }], its own first. */
async function checkouts(dir) {
  const blocks = (await git(dir, ["worktree", "list", "--porcelain"])).split(/\n\n+/);
  return blocks.map((block) => {
    const field = (name) => block.split("\n").find((l) => l.startsWith(`${name} `))?.slice(name.length + 1);
    return { path: field("worktree"), branch: field("branch")?.replace(/^refs\/heads\//, "") ?? null };
  }).filter((c) => c.path);
}

/**
 * Where the ticket's agent will work in a project:
 * - `existing`: { path, branch, changes }, a checkout that is already the ticket's: the folder a
 *   new worktree would get, or wherever the ticket's branch is checked out (git allows a branch
 *   one checkout only). The agent continues there.
 * - else a new worktree: on the ticket's branch if there is one (`branchExists`), else on a new
 *   one from `base`, the project's base branch (null: its remote has none of BASE_BRANCHES).
 */
async function projectState(dir, key) {
  const refs = BASE_BRANCHES.map((b) => `refs/remotes/origin/${b}`);
  const found = (await git(dir, ["for-each-ref", "--format=%(refname:short)", ...refs, `refs/heads/${key}`])).split("\n");
  const base = BASE_BRANCHES.find((b) => found.includes(`origin/${b}`)) ?? null;
  const target = `${ROOT}/${worktreeDir(dir, key)}`;
  const all = await checkouts(dir);
  const existing = all.find((c) => c.path === target) ?? all.find((c) => c.branch === key) ?? null;
  if (existing) {
    const status = await exec("git", ["status", "--porcelain"], { cwd: existing.path });
    existing.changes = status.stdout.split("\n").filter(Boolean).length;
  }
  return { base, existing, branchExists: found.includes(key) };
}

/** Keeps the worktrees out of the project's `git status`, unless its .gitignore already does:
 *  a line in the repo's own exclude file, which is never committed. */
async function excludeWorktrees(dir) {
  const ignored = await exec("git", ["check-ignore", "-q", `${WORKTREES}/x`], { cwd: `${ROOT}/${dir}` });
  if (ignored.code === 0) return;
  const file = `${ROOT}/${dir}/.git/info/exclude`;
  const text = await readTextFile(file);
  const before = text && !text.endsWith("\n") ? `${text}\n` : text ?? "";
  await writeTextFile(file, `${before}/${WORKTREES}/\n`, text);
}

/** Makes the ticket's worktree (see projectState) and answers its folder. The new branch
 *  starts at the remote's base branch as it is now, and doesn't track it: a plain `git push`
 *  must never go to dev. */
async function prepareCheckout(dir, key, state) {
  if (state.existing) return state.existing.path;
  const path = `${ROOT}/${worktreeDir(dir, key)}`;
  await excludeWorktrees(dir);
  if (state.branchExists) {
    await mustGit(dir, ["worktree", "add", path, key]);
  } else {
    await mustGit(dir, ["fetch", "origin", state.base], FETCH_TIMEOUT_MS);
    await mustGit(dir, ["worktree", "add", "--no-track", "-b", key, path, `origin/${state.base}`]);
  }
  return path;
}

export default class Handover extends View {
  init(_props, cx) {
    const p = props() ?? {};
    this.task = p.task ?? { key: "", summary: "" };
    this.handle = cx.focus_handle();
    if (p.menu) { this.handle.focus(); return; }

    this.projects = null; // [{ alias, dir }], once listed
    this.project = null; // the chosen dir
    this.states = new Map(); // dir -> projectState
    this.sentence = instruction(this.task, null); // the instruction the message holds now
    this.starting = false; // making the worktree
    this.error = null; // why that failed
    this.plan = false;
    this.query = "";

    this.search = InputState.new({ placeholder: "Search projects…" });
    this.search.on("change", (_e, cx) => { this.query = this.search.value(); cx.notify(); });
    this.search.on("submit", (_e, cx) => {
      const [first] = this.matches();
      if (first) { this.choose(first.dir, cx); this.message.focus(); }
    });
    this.message = TextareaState.new({ value: this.sentence, rows: 4 });
    this.search.focus();
    cx.timer.after(300, () => this.search.focus());

    cx.spawn(async (cx) => {
      this.projects = await listProjects();
      const guess = this.guess();
      if (guess) this.choose(guess, cx);
      cx.notify();
    });
  }

  // --- the dialog's state ---

  /** The pinned project the ticket's title names ("Matcher: walking floor"), if any. */
  guess() {
    const words = (this.task.summary ?? "").toLowerCase().split(/[^a-z0-9]+/);
    const named = (p) => words.includes(p.alias) || words.includes(p.dir.split("-")[0]);
    return this.projects.find((p) => p.alias && named(p))?.dir ?? null;
  }

  matches() {
    const q = this.query.trim().toLowerCase();
    const all = this.projects ?? [];
    return q ? all.filter((p) => `${p.alias ?? ""} ${p.dir}`.toLowerCase().includes(q)) : all;
  }

  choose(dir, cx) {
    if (this.starting) return;
    this.project = dir;
    this.error = null;
    cx.notify();
    if (this.states.has(dir)) { this.describe(this.states.get(dir)); return; }
    cx.spawn(async (cx) => {
      this.states.set(dir, await projectState(dir, this.task.key));
      if (this.project === dir) this.describe(this.states.get(dir));
      cx.notify();
    });
  }

  // The message is the person's to edit: a change here only swaps the sentence it put there.
  describe(state) {
    const next = instruction(this.task, state);
    if (next === this.sentence) return;
    this.message.set_value(this.message.value().replace(this.sentence, next));
    this.sentence = next;
  }

  togglePlan(cx) {
    this.plan = !this.plan;
    const text = this.message.value().replace(PLAN, "").trimEnd();
    this.message.set_value(this.plan ? `${text} ${PLAN}`.trimStart() : text);
    cx.notify();
  }

  // The project's state is asked for when it's chosen; a start before the answer waits for it.
  ready() {
    const state = this.states.get(this.project);
    const possible = state && (state.existing || state.branchExists || state.base);
    return Boolean(possible && !this.starting && this.message.value().trim());
  }

  start(cx) {
    if (!this.ready()) return;
    const { project, task } = this;
    const overlay = props().overlay;
    this.starting = true;
    this.error = null;
    cx.notify();
    cx.spawn(async (cx) => {
      try {
        const folder = await prepareCheckout(project, task.key, this.states.get(project));
        closeOverlay(overlay);
        // Into the Tickets space (my-spaces keeps it), whichever space is shown now.
        const tickets = spaces().find((s) => !s.machine && s.name.toLowerCase() === "tickets");
        run("tab.new", { name: task.key, folder, argv: AGENT, task: this.message.value().trim(), ...(tickets ? { space: tickets.id } : {}) });
      } catch (e) {
        this.error = String(e?.message ?? e);
        this.starting = false;
        this.states.delete(project); // whatever failed, look again
        this.choose(project, cx);
      }
    });
  }

  // --- drawing ---

  menu(t) {
    const open = () => {
      closeOverlay(props().overlay);
      openOverlay({ mod: MOD, kind: "dialog", width: 560, height: 540, props: { task: this.task } });
    };
    return v_flex().id("handover-menu").track_focus(this.handle)
      .on_key_down((e, cx) => { if (e.key === "enter") { open(); cx.stop_propagation(); } })
      .size_full().p(5).bg(t.popover).text_size(12.8)
      .child(h_flex().id("hand-over")
        .h(31).px(9).rounded(7).items_center().cursor_pointer()
        .bg(t.selected).text_color(t.foreground)
        .on_click(open)
        .child("Hand over to Claude"));
  }

  projectRow(t, p) {
    const on = p.dir === this.project;
    return h_flex().id(`project-${p.dir}`)
      .h(28).px(8).gap(8).flex_none().items_center().rounded(6).cursor_pointer()
      .when(on, (el) => el.bg(t.selected))
      .hover((s) => s.bg(on ? t.selected : t.hover))
      .on_click((_e, cx) => this.choose(p.dir, cx))
      .child(div().text_color(t.foreground).child(p.alias ?? p.dir))
      .when(Boolean(p.alias), (el) => el.child(div().text_size(11.5).text_color(t.dim).child(p.dir)));
  }

  projectList(t) {
    const matches = this.matches();
    const empty = this.projects ? "No project matches." : "Looking for projects…";
    return v_flex().id("projects")
      .h(150).flex_none().p(4).gap(1).overflow_y_scrollbar()
      .rounded(9).border_1().border_color(t.input).bg(t.background)
      .children(matches.map((p) => this.projectRow(t, p)))
      .when(!matches.length, (el) => el.child(div().px(8).py(5).text_color(t.dim).child(empty)));
  }

  /** Where the agent will work. */
  checkoutNote(t) {
    const state = this.states.get(this.project);
    const { key } = this.task;
    if (this.error) return div().text_color(t.blocked).child(`Couldn't make the worktree: ${this.error}`);
    if (!this.project) return div().text_color(t.blocked).child("Choose a project.");
    if (!state) return div().text_color(t.dim).child("Checking the project…");
    if (this.starting) return div().text_color(t.dim).child("Making the worktree…");
    if (state.existing) {
      const { path, branch, changes } = state.existing;
      const dirty = changes ? `, ${changes} uncommitted change${changes > 1 ? "s" : ""}` : "";
      return div().text_color(changes ? t.working : t.dim)
        .child(`Continues in ${short(path)} (on ${branch ?? "a detached HEAD"}${dirty}).`);
    }
    const folder = worktreeDir(this.project, key);
    if (state.branchExists) {
      return div().text_color(t.dim).child(`New worktree ${folder}, on the existing branch ${key}.`);
    }
    if (!state.base) {
      return div().text_color(t.blocked)
        .child(`No ${BASE_BRANCHES.join(", ")} branch on origin to start ${key} from.`);
    }
    return div().text_color(t.dim)
      .child(`New worktree ${folder}, on a new branch ${key} from the latest ${state.base}.`);
  }

  planCheckbox(t) {
    const mark = svg("mods/tasks/check.svg").size(12).text_color(t.background);
    return h_flex().id("plan")
      .gap(8).items_center().cursor_pointer().text_color(t.foreground)
      .on_click((_e, cx) => this.togglePlan(cx))
      .child(div()
        .flex_none().size(16).flex().items_center().justify_center()
        .rounded(4).border_1().border_color(this.plan ? t.accent : t.input)
        .bg(this.plan ? t.accent : t.background)
        .children(this.plan ? [mark] : []))
      .child("Plan the changes first");
  }

  button(t, id, text, primary, enabled, action) {
    return h_flex().id(id)
      .h(32).px(14).items_center().rounded(8).border_1()
      .border_color(primary ? t.solid : t.input).bg(primary ? t.solid : t.raised)
      .text_color(primary ? t.solid_foreground : t.foreground).font_medium()
      .when(enabled, (el) => el.cursor_pointer().hover((s) => s.opacity(0.88)).on_click(action))
      .when(!enabled, (el) => el.opacity(0.45))
      .child(text);
  }

  dialog(t) {
    const label = (text) => div().pt(14).pb(6).text_size(11.5).text_color(t.dim).child(text);
    const frame = (el) => el.px(10).rounded(9).border_1().border_color(t.input).bg(t.background)
      .text_size(12.8).text_color(t.foreground);
    const close = () => closeOverlay(props().overlay);
    return v_flex().id("handover").track_focus(this.handle)
      .on_key_down((e, cx) => {
        if (e.key === "escape") close();
        else if (e.key === "enter" && (e.modifiers.control || e.modifiers.platform)) this.start(cx);
        else return;
        cx.stop_propagation();
      })
      .size_full().min_h(0).p(18).bg(t.popover).text_color(t.foreground).text_size(12.5)
      .child(h_flex().items_center()
        .child(div().flex_1().text_size(15).font_semibold().child(`Hand over ${this.task.key} to Claude`))
        .child(div().text_size(11).text_color(t.dim).child("Esc")))
      .child(div().pt(4).truncate().text_color(t.muted).child(this.task.summary || "(no summary)"))
      .child(label("Project"))
      .child(frame(Input.new(this.search)).h(34).mb(6))
      .child(this.projectList(t))
      .child(div().pt(6).text_size(11.5).child(this.checkoutNote(t)))
      .child(label("First message"))
      .child(frame(Textarea.new(this.message)).py(6))
      .child(div().flex_1())
      .child(h_flex().pt(14).gap(8).items_center()
        .child(this.planCheckbox(t))
        .child(div().flex_1())
        .child(this.button(t, "cancel", "Cancel", false, true, close))
        .child(this.button(t, "start", "Start agent", true, this.ready(), (_e, cx) => this.start(cx))));
  }

  render() {
    const t = theme();
    return props()?.menu ? this.menu(t) : this.dialog(t);
  }
}
