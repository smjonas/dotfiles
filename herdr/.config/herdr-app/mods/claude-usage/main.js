// Claude plan usage (5h session + weekly) for the status bar.
// Reads Claude Code's OAuth token from ~/.claude/.credentials.json and polls
// the same endpoint `/usage` in Claude Code uses. When the access token is
// (nearly) expired we refresh it the way Claude Code does and write the new
// tokens back, like a second Claude Code instance would: refresh tokens rotate,
// so the file must hold the new one or Claude Code's next refresh would fail.
// Running Claude Code sessions re-read the file when their token goes stale.
import { View, div } from "gpui-kit";
import { h_flex } from "gpui-base";
import { theme, home, readTextFile, writeTextFile, exec, checking } from "herdr";

const URL = "https://api.anthropic.com/api/oauth/usage";
const TOKEN_URL = "https://platform.claude.com/v1/oauth/token";
const CLIENT_ID = "9d1c250a-e61b-44d9-88ed-5944d1962f5e"; // Claude Code's
const REFRESH_MARGIN_MS = 5 * 60 * 1000;
// The endpoint is undocumented and known to answer 429 when polled often
// (Claude Code sessions poll it too, sharing the same limit). herdr's fetch
// exposes no headers, so retry-after can't be read: back off exponentially.
const POLL_MS = 5 * 60 * 1000;
const MAX_BACKOFF_MS = 60 * 60 * 1000;

const credPath = () => `${home()}/.claude/.credentials.json`;

// Exchanges the refresh token and saves the result back into the credentials file.
async function refreshToken(raw) {
  const oauth = JSON.parse(raw).claudeAiOauth;
  if (!oauth?.refreshToken) throw new Error("token expired, no refresh token (run claude)");
  const res = await fetch(TOKEN_URL, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      grant_type: "refresh_token",
      refresh_token: oauth.refreshToken,
      client_id: CLIENT_ID,
      scope: (oauth.scopes ?? []).join(" "),
    }),
  });
  if (!res.ok) throw new Error(`token refresh failed: HTTP ${res.status} (run claude)`);
  const t = await res.json();
  const fresh = {
    accessToken: t.access_token,
    refreshToken: t.refresh_token ?? oauth.refreshToken,
    expiresAt: Date.now() + t.expires_in * 1000,
    ...(t.refresh_token_expires_in ? { refreshTokenExpiresAt: Date.now() + t.refresh_token_expires_in * 1000 } : {}),
    ...(t.scope ? { scopes: t.scope.split(" ") } : {}),
  };
  // The old refresh token is now spent, so the new one must reach the file.
  // Retry on a stale snapshot, merging into whatever is there now, unless
  // Claude Code refreshed in the meantime (its refresh token differs from ours).
  for (let attempt = 0; attempt < 3; attempt++) {
    const cur = attempt === 0 ? raw : await readTextFile(credPath());
    const c = JSON.parse(cur);
    if (attempt > 0 && c.claudeAiOauth?.refreshToken !== oauth.refreshToken) break;
    c.claudeAiOauth = { ...c.claudeAiOauth, ...fresh };
    try {
      await writeTextFile(credPath(), JSON.stringify(c), cur);
      await exec("chmod", ["600", credPath()]);
      break;
    } catch {}
  }
  return t.access_token;
}

async function accessToken({ force = false } = {}) {
  const raw = await readTextFile(credPath());
  const oauth = raw && JSON.parse(raw).claudeAiOauth;
  if (!oauth?.accessToken) throw new Error("not logged in");
  if (force || (oauth.expiresAt && oauth.expiresAt - REFRESH_MARGIN_MS < Date.now())) {
    if (checking()) throw new Error("token expired");
    return refreshToken(raw);
  }
  return oauth.accessToken;
}

function fmtLeft(iso) {
  if (!iso) return "";
  let s = Math.max(0, Math.round((Date.parse(iso) - Date.now()) / 1000));
  const d = Math.floor(s / 86400); s -= d * 86400;
  const h = Math.floor(s / 3600); s -= h * 3600;
  const m = Math.floor(s / 60);
  if (d > 0) return `${d}d${h}h`;
  if (h > 0) return `${h}h${String(m).padStart(2, "0")}m`;
  return `${m}m`;
}

function fmtAt(iso) {
  if (!iso) return "";
  const d = new Date(iso);
  const p = (n) => String(n).padStart(2, "0");
  const day = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"][d.getDay()];
  return `${day} ${p(d.getHours())}:${p(d.getMinutes())}`;
}

function fmtAgo(ms) {
  if (!ms) return "never";
  const d = new Date(ms);
  const p = (n) => String(n).padStart(2, "0");
  const m = Math.floor((Date.now() - ms) / 60000);
  const ago = m < 1 ? "just now" : m < 60 ? `${m}m ago` : `${Math.floor(m / 60)}h${p(m % 60)}m ago`;
  return `${p(d.getHours())}:${p(d.getMinutes())} (${ago})`;
}

export default class ClaudeUsage extends View {
  init(_props, cx) {
    this.data = null;
    this.error = null;
    this.loading = false;
    this.delay = POLL_MS;
    this.nextAt = 0;
    this.refresh(cx);
    // One minute tick: keeps the "resets in" countdown fresh and polls when due.
    cx.timer.every(60 * 1000, (cx) => {
      if (Date.now() >= this.nextAt) this.refresh(cx);
      cx.notify();
    });
  }

  refresh(cx) {
    if (this.loading) return;
    this.loading = true;
    cx.spawn(async (cx) => {
      try {
        const get = (token) => fetch(URL, {
          headers: {
            Authorization: `Bearer ${token}`,
            "anthropic-beta": "oauth-2025-04-20",
            "Content-Type": "application/json",
          },
        });
        let res = await get(await accessToken());
        // Revoked or expired early despite expiresAt: refresh once and retry.
        if (res.status === 401) res = await get(await accessToken({ force: true }));
        if (res.status === 429) {
          this.delay = Math.min(this.delay * 2, MAX_BACKOFF_MS);
          throw new Error(`rate limited, retry in ${Math.round(this.delay / 60000)}m`);
        }
        if (!res.ok) throw new Error(`HTTP ${res.status}`);
        this.data = await res.json();
        this.fetchedAt = Date.now();
        this.error = null;
        this.delay = POLL_MS;
      } catch (e) {
        this.error = String(e?.message ?? e);
      } finally {
        this.nextAt = Date.now() + this.delay;
        this.loading = false;
        cx.notify();
      }
    });
  }

  color(t, pct) {
    if (pct >= 90) return t.blocked;
    if (pct >= 70) return t.ansi3;
    return t.ansi2;
  }

  meter(t, id, label, win) {
    const pct = Math.round(win?.utilization ?? 0);
    const c = this.color(t, pct);
    const W = 46;
    return h_flex().id(id).gap(6).items_center()
      .tooltip(`${label}: ${pct}% used` + (win?.resets_at ? ` · resets ${fmtAt(win.resets_at)}` : "")
        + `\nLast fetch: ${fmtAgo(this.fetchedAt)}` + (this.error ? `\nLast refresh failed: ${this.error}` : ""))
      .child(div().text_color(t.dim).child(label))
      .child(div().w(W).h(5).rounded(3).bg(t.border)
        .child(div().h_full().rounded(3).bg(c).w(Math.max(2, Math.min(W, (W * pct) / 100)))))
      .child(div().text_color(pct >= 70 ? c : t.muted).child(`${pct}%`))
      .when(Boolean(win?.resets_at), (el) => el.child(div().text_color(t.dim).child(fmtLeft(win.resets_at))));
  }

  render() {
    const t = theme();
    const root = h_flex().id("claude-usage").size_full().px(14).gap(14).items_center().justify_end()
      .bg(t.chrome).border_t(1).border_color(t.border).text_size(11.8).text_color(t.muted);
    if (!this.data) {
      return root
        .child(div().text_color(this.error ? t.blocked : t.dim).truncate()
          .child(this.error ? `Claude: ${this.error}` : "Claude usage…"));
    }
    return root.when(Boolean(this.error), (el) => el.tooltip(`Last refresh failed: ${this.error}\nLast fetch: ${fmtAgo(this.fetchedAt)}`))
      .child(this.meter(t, "u5h", "5h", this.data.five_hour))
      .child(this.meter(t, "u7d", "week", this.data.seven_day))
      .when(Boolean(this.error), (el) => el.child(div().text_color(t.blocked).child("!")));
  }
}
