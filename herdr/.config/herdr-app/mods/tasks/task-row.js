// What both views show of one task, in up to three lines:
//   NCP-1234  in review  NEXT                  3h  agent →  (extra)
//   The ticket's title
//   reasons · MRs with their pipeline
import { div } from "gpui-kit";
import { v_flex, h_flex } from "gpui-base";
import { run } from "herdr";
import { ago, compact, isTicket, link, strongButton } from "./kit.js";

/**
 * `pane`: the herdr pane running the task's agent, if known. `done`: checked off today, so
 * shown struck through and without its live details. `extra`: elements for the end of line one.
 */
export function taskDetails(t, task, { pane = null, done = false, extra = [] } = {}) {
  return v_flex().flex_1().min_w(0).gap(3)
    .child(headline(t, task, { pane, done, extra }))
    .child(title(t, task, done))
    .children(compact([!done && reasonsAndMrs(t, task)]));
}

function headline(t, task, { pane, done, extra }) {
  const dim = (text) => div().flex_none().text_color(t.dim).child(text);
  return h_flex().gap(8).items_center().text_size(11.5).children(compact([
    keyLabel(t, task, done),
    task.status && dim(task.status),
    task.next && !done && nextTag(t, task),
    div().flex_1(),
    task.since && !done && dim(ago(task.since)),
    pane && !done && agentButton(t, task, pane),
    ...extra,
  ]));
}

// A ticket links to Jira; an agent session without a ticket only has its id.
function keyLabel(t, task, done) {
  if (isTicket(task.key)) {
    return link(t, `key-${task.key}`, task.key, task.url, done ? t.dim : t.accent);
  }
  return div().flex_none().text_color(t.muted).child(task.key.replace(/^session:/, ""));
}

function nextTag(t, task) {
  return div().id(`next-${task.key}`)
    .flex_none().px(5).rounded(4)
    .bg(t.accent).text_color(t.accent_foreground).text_size(10.5).font_semibold()
    .tooltip(`Next: ${task.next}`)
    .child("NEXT");
}

function agentButton(t, task, pane) {
  const focus = () => run("pane.focus", { pane });
  return strongButton(t, `agent-${task.key}`, "agent →", "Go to the agent", focus);
}

function title(t, task, done) {
  const text = isTicket(task.key) ? task.summary : (task.sessions?.[0]?.prompt ?? task.key);
  return div()
    .text_size(12.8).text_color(done ? t.dim : t.foreground)
    .when(done, (el) => el.line_through())
    .child(text || "(no summary)");
}

function reasonsAndMrs(t, task) {
  const reasons = task.reasons ?? [];
  const mrs = task.mrs ?? [];
  if (!reasons.length && !mrs.length) return null;
  return h_flex().gap(8).items_center().flex_wrap().text_size(11.5).children(compact([
    reasons.length > 0 && div().text_color(reasonColor(t, task)).child(reasons.join(" · ")),
    ...mrs.map((mr) => mergeRequest(t, task, mr)),
  ]));
}

function mergeRequest(t, task, mr) {
  return h_flex().gap(4).items_center()
    .child(div().size(6).rounded(3).bg(pipelineColor(t, mr)))
    .child(link(t, `mr-${task.key}-${mr.ref}`, mr.ref, mr.url, t.muted));
}

function reasonColor(t, task) {
  if (task.group === "Needs you") return t.blocked;
  if (task.group === "In flight") return t.working;
  return t.dim;
}

function pipelineColor(t, mr) {
  if (mr.pipeline === "failed") return t.blocked;
  if (mr.pipeline === "success") return t.ansi2;
  return mr.pipeline ? t.working : t.dim; // running, or no pipeline
}
