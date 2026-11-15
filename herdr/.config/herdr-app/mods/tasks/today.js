// The Today view: a field to add tickets, yesterday's leftovers, and the day's numbered
// checklist, reordered by dragging a row's grip. `view` is the Tasks view (main.js), which
// holds the state and the actions.
import { div } from "gpui-kit";
import { v_flex, h_flex } from "gpui-base";
import { checkbox, field, note, quietButton } from "./kit.js";
import { taskDetails, withHandOver } from "./task-row.js";

export function todayView(view, t, agentPanes) {
  const day = view.day;
  const out = [field(t, "add", view.input, Boolean(view.query))];
  const suggestions = view.suggestions();
  if (suggestions.length) out.push(suggestionList(view, t, suggestions));
  if (!day) return [...out, note(t, "Loading today…")];
  if (day.carry?.length) out.push(carryOver(view, t, day));
  if (!day.items.length) {
    return [...out, note(t, "Nothing planned yet. Search above, or use + today in All.")];
  }
  return [...out, ...rows(view, t, agentPanes)];
}

// --- adding ---

function suggestionList(view, t, suggestions) {
  return v_flex()
    .mx(2).mb(6).p(4).gap(1)
    .rounded(8).bg(t.raised).border_1().border_color(t.border)
    .children(suggestions.map((s, i) => suggestion(view, t, s, i === 0)));
}

// Enter adds the first one, so it looks hovered and shows the key.
function suggestion(view, t, s, first) {
  return h_flex().id(`sugg-${s.key}`)
    .px(8).py(5).gap(8).items_center().rounded(5).cursor_pointer()
    .when(first, (el) => el.bg(t.hover))
    .hover((st) => st.bg(t.hover))
    .on_click((_e, cx) => view.add(s.key, cx))
    .child(div().flex_none().text_size(11.5).text_color(t.accent).child(s.key))
    .child(div().flex_1().min_w(0).truncate().text_size(12.5)
      .text_color(s.typed ? t.dim : t.foreground)
      .child(s.typed ? "add by number" : s.summary))
    .when(first, (el) => el.child(div().flex_none().text_size(11).text_color(t.dim).child("↵")));
}

function carryOver(view, t, day) {
  return h_flex().id("carry")
    .mx(2).mb(4).px(10).py(7).gap(8).items_center()
    .rounded(7).border_1().border_color(t.border).cursor_pointer()
    .text_size(12.5).text_color(t.muted)
    .hover((s) => s.bg(t.hover).text_color(t.foreground))
    .tooltip(day.carry.join(", "))
    .on_click((_e, cx) => view.loadDay(cx, ["carry"]))
    .child(div().text_color(t.accent).child("↻"))
    .child(`Carry over ${day.carry.length} open from ${day.carry_from}`);
}

// --- the checklist ---

// While dragging, the lifted row leaves the list and a placeholder of its height takes the
// slot. The other rows are numbered as they will be after the drop.
function rows(view, t, agentPanes) {
  const { drag, slot } = view;
  const items = view.day.items;
  if (!drag) return items.map((item, i) => row(view, t, item, i, i + 1, agentPanes));
  const rest = items.filter((item) => item.key !== drag.key);
  const out = rest.map((item, i) => row(view, t, item, i, i < slot ? i + 1 : i + 2, agentPanes));
  out.splice(Math.min(slot, rest.length), 0, placeholder(t, drag.h));
  return out;
}

const rowShell = (id) => (id ? h_flex().id(id) : h_flex()).px(4).py(6).gap(4).items_start().rounded(7);

const grip = (t, color, id) => (id ? div().id(id) : div())
  .flex_none().w(14).pt(1).text_size(13).text_color(color).child("⠿");

const number = (t, n, done) => div()
  .flex_none().w(18).pt(1).text_size(12).text_color(done ? t.dim : t.muted).child(`${n}.`);

const spacer = () => div().w(6).flex_none();

/** `at`: the row's index among the rows shown (without the lifted one). */
function row(view, t, item, at, n, agentPanes) {
  const key = item.key;
  const remove = quietButton(t, `rm-${key}`, "✕", "Remove from today", (cx) => view.remove(key, cx));
  const task = view.withLiveDetails(item);
  return withHandOver(rowShell(`today-${key}`), item.done ? item : task)
    .when(!view.drag, (el) => el.hover((s) => s.bg(t.hover)))
    .on_size_change((size) => { view.heights[key] = size.height; })
    .on_mouse_move((e, cx) => view.hoverRow(at, e, cx))
    .child(grip(t, t.dim, `grip-${key}`)
      .cursor_grab()
      .hover((s) => s.text_color(t.foreground))
      .tooltip("Drag to reorder")
      .on_mouse_down("left", (e, cx) => { cx.stop_propagation(); view.lift(item, at, e, cx); }))
    .child(number(t, n, item.done))
    .child(checkbox(t, item.done, `check-${key}`, (cx) => view.toggle(item, cx)))
    .child(spacer())
    .child(taskDetails(t, task, {
      pane: agentPanes.get(key),
      done: item.done,
      extra: [remove],
    }));
}

function placeholder(t, height) {
  return div().h(height).my(1).rounded(7).border_1().border_dashed().border_color(t.input);
}

/**
 * The lifted row, following the pointer above the list; null when nothing is lifted.
 * Nothing in it reacts to the mouse, so the rows underneath keep getting the pointer.
 */
export function liftedRow(view, t) {
  const { drag, pointer } = view;
  if (!drag || !pointer) return null;
  const item = view.day?.items.find((i) => i.key === drag.key);
  if (!item) return null;
  return rowShell()
    .absolute().left(10).top(pointer.y - drag.dy).w(Math.max(0, view.width - 20)).h(drag.h)
    .bg(t.raised).border_1().border_color(t.accent).shadow_lg().opacity(0.95)
    .child(grip(t, t.foreground))
    .child(number(t, view.slot + 1, item.done))
    .child(checkbox(t, item.done))
    .child(spacer())
    .child(v_flex().flex_1().min_w(0).gap(3)
      .child(div().text_size(11.5).text_color(t.accent).child(item.key))
      .child(div().text_size(12.8).text_color(t.foreground)
        .child(view.withLiveDetails(item).summary || "(no summary)")));
}
