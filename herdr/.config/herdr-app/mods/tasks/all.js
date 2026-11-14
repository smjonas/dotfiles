// The All view: everything `task ls` lists, under its group headings, with a filter.
// `view` is the Tasks view (main.js).
import { div } from "gpui-kit";
import { h_flex } from "gpui-base";
import { field, isTicket, note, quietButton } from "./kit.js";
import { taskDetails } from "./task-row.js";

export function allView(view, t, agentPanes) {
  const out = [field(t, "filter", view.filterInput, Boolean(view.filter))];
  if (!view.tasks) return view.loading ? [...out, note(t, "Asking Jira and GitLab…")] : out;

  const query = view.filter.trim().toLowerCase();
  const shown = query ? view.tasks.filter((task) => searchText(task).includes(query)) : view.tasks;
  if (!shown.length) return [...out, note(t, query ? "No task matches." : "Nothing in flight.")];

  let group = null;
  shown.forEach((task, i) => {
    if (task.group !== group) {
      group = task.group;
      const count = shown.filter((x) => x.group === group).length;
      out.push(groupHeading(t, group, count, i === 0));
    }
    out.push(card(view, t, task, agentPanes.get(task.key)));
  });
  return out;
}

// Everything a task shows, for the filter.
function searchText(task) {
  return [
    task.key, task.summary, task.status, task.group,
    ...(task.reasons ?? []),
    ...(task.mrs ?? []).map((mr) => mr.ref),
    ...(task.sessions ?? []).map((s) => s.prompt),
  ].join(" ").toLowerCase();
}

function groupHeading(t, group, count, first) {
  return h_flex()
    .px(6).pt(first ? 2 : 12).pb(2).gap(6)
    .text_size(11).text_color(t.muted).font_semibold()
    .child(group.toUpperCase())
    .child(div().text_color(t.dim).child(String(count)));
}

// The outlined card is task's NEXT.
function card(view, t, task, pane) {
  return div().id(`task-${task.key}`)
    .px(10).py(7).rounded(7)
    .when(Boolean(task.next), (el) => el.bg(t.raised).border(1).border_color(t.accent))
    .hover((s) => s.bg(t.hover))
    .child(taskDetails(t, task, { pane, extra: todayMark(view, t, task) }));
}

// A ticket's place on today's list (so the order of the day shows here too), or a button to
// put it there. Agent sessions without a ticket can't be planned.
function todayMark(view, t, task) {
  if (!isTicket(task.key)) return [];
  const at = view.todayIndex(task.key);
  if (at < 0) {
    const plan = (cx) => view.add(task.key, cx);
    return [quietButton(t, `plan-${task.key}`, "+ today", "Add to today's list", plan)];
  }
  const done = view.day.items[at].done;
  return [div().id(`planned-${task.key}`)
    .flex_none().px(6).rounded(4).text_size(11).font_semibold()
    .bg(done ? t.surface : t.selected).text_color(done ? t.dim : t.foreground)
    .tooltip(done ? "Done today" : `#${at + 1} on today's list`)
    .child(done ? "today ✓" : `today #${at + 1}`)];
}
