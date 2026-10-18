# cr: claude resume

fzf picker over all Claude Code sessions, from the host (`~/.claude`) and from the
claude-neocargo container (`~/.claude-neocargo`). Unlike `/resume`, it searches the whole
conversation (prompts, replies, shell commands, file paths), not just the title.

```
cr                      all sessions, newest first
cr kimai password       prefilled query
cr .                    only the current folder's project
cr -p                   pick project(s) first
cr --reindex            rebuild the cache
```

Enter resumes the session in its folder, with `claude` for host sessions and `claude-neocargo`
for container sessions.

## Query

| | |
|---|---|
| `word word` | every word must match (title, project, branch or conversation text; smart case) |
| `wrod` | a word that matches nothing at all falls back to fuzzy matching on titles (shown dimmed, `~fuzzy`) |
| `"exact phrase"` | phrase |
| `-word` | exclude |
| `@proj` | project (substring of name or path; the picker inserts exact names; several = OR) |
| `:h` / `:c` | host / container only |

## Keys

| | |
|---|---|
| enter | resume |
| ctrl-o | cycle all → host → container |
| alt-p | project picker (tab for multiple) |
| alt-o | open the transcript in nvim at the first match (`CR_VIEWER` overrides). Not alt-v: fzf 0.42 reads that as page-up |
| ctrl-y | copy `cd … && claude --resume …` to the clipboard, e.g. to resume in another pane |
| ctrl-/ | toggle preview |

## Ranking

Sessions are grouped by how well the words matched, newest first within each group: every word at
the start of a word in the title or project, then at the start of a word anywhere in the
conversation, then anywhere inside a word, then fuzzy.

## Rows and preview

Row: last activity (minutes, today's time, weekday within the last week, then 9d / 3w / date), origin (**H** yellow = host, **C** cyan = container) + project, number of
prompts, git branch, title (your `/rename` name, otherwise the AI title, otherwise the first
prompt). Sessions that were continued in another session are dimmed.

Preview: started / last active / span, prompts and replies, model, cost and lines changed, linked
MRs, the session id. Then either every prompt (one line each) or, with a query, the matching
lines with context.

## How it stays fast

On start, `cr` reparses only session files whose mtime or size changed, into
`~/.cache/claude-resume/`: `index.json` (metadata) and one plain-text transcript per session
(tool output left out; the folder is private because transcripts can hold secrets). Each keystroke runs `rg -l` over those transcripts.

Projects are named relative to the folders in `CR_ROOTS` (default `~/Desktop/NeoCargo`,
colon-separated), otherwise after the folder's name.

Needs fzf ≥ 0.42, ripgrep and python3.
