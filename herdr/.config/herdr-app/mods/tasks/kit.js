// Small stateless pieces of the Tasks panel. `t` is herdr's theme().
import { div, svg } from "gpui-kit";
import { Input } from "gpui-base";

/** The children that are there, so a list of children can say `condition && element`. */
export const compact = (children) => children.filter(Boolean);

export const isTicket = (key) => key.startsWith("NCP-");

/** How long ago `secs` (epoch seconds) was: "now", "5m", "3h", "2d". */
export function ago(secs) {
  if (!secs) return "";
  const minutes = Math.floor((Date.now() / 1000 - secs) / 60);
  if (minutes < 1) return "now";
  if (minutes < 60) return `${minutes}m`;
  const hours = Math.floor(minutes / 60);
  return hours < 48 ? `${hours}h` : `${Math.floor(hours / 24)}d`;
}

// Hover, click and tooltip need an id; an element without them doesn't.
const box = (id) => (id ? div().id(id) : div());

const stop = (_e, cx) => cx.stop_propagation();

/** Something small to click inside a row. The row never sees the click. */
function pressable(id, tip, onClick) {
  return div().id(id)
    .flex_none().cursor_pointer().px(6).rounded(4)
    .tooltip(tip)
    .on_mouse_down("left", stop)
    .on_click((_e, cx) => { cx.stop_propagation(); onClick(cx); });
}

/** A quiet text button: "✕", "+ today". */
export function quietButton(t, id, label, tip, onClick) {
  return pressable(id, tip, onClick)
    .text_color(t.dim)
    .hover((s) => s.bg(t.hover).text_color(t.foreground))
    .child(label);
}

/** A button that stands out: "agent →". */
export function strongButton(t, id, label, tip, onClick) {
  return pressable(id, tip, onClick)
    .bg(t.selected).text_color(t.foreground)
    .hover((s) => s.bg(t.accent).text_color(t.accent_foreground))
    .child(label);
}

export function link(t, id, text, url, color = t.accent) {
  return div().id(id)
    .flex_none().cursor_pointer()
    .text_color(color)
    .hover((s) => s.underline())
    .on_click((_e, cx) => { cx.stop_propagation(); if (url) cx.open_url(url); })
    .child(text);
}

/** One dim line of text: "Loading today…", or an error in `color`. */
export function note(t, text, color = t.dim) {
  return div().px(6).py(4).text_size(12).text_color(color).child(text);
}

/** A text input in a rounded frame, outlined in the accent colour while it holds text. */
export function field(t, id, state, active) {
  return div().id(id)
    .mx(2).mb(6).h(32).px(10).flex().items_center()
    .rounded(8).border_1().border_color(active ? t.accent : t.border)
    .cursor_text()
    .child(Input.new(state).w_full().h_full().text_size(12.5).text_color(t.foreground));
}

/** A checkbox; without `onClick` it only shows its state. */
export function checkbox(t, done, id, onClick) {
  const mark = svg("mods/tasks/check.svg").size(12).text_color(t.background);
  const el = box(id)
    .flex_none().size(16).mt(1).flex().items_center().justify_center()
    .rounded(4).border_1().border_color(done ? t.ansi2 : t.input)
    .bg(done ? t.ansi2 : t.surface)
    .children(compact([done && mark]));
  if (!onClick) return el;
  return el.cursor_pointer()
    .on_mouse_down("left", stop)
    .on_click((_e, cx) => onClick(cx));
}
