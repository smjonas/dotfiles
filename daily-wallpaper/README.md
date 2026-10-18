# daily-wallpaper

Every morning Claude (Sonnet 5.5) picks one image set for the
[Cinnamon Dynamic Wallpaper](https://github.com/TobiZog/cinnamon-dynamic-wallpaper) extension. It
looks at the Karlsruhe forecast (Open-Meteo), the season, the weekday and the last 14 picks. The
extension keeps switching images by time of day.

Claude runs as a single `claude-neocargo -p` call (the `cc` wrapper from `agents-config`), so it
uses that Claude Code login, no API key. Tools, MCP servers, skills and session saving are off,
so a pick is about 2k input and 100 output tokens.

```
daily-wallpaper              pick today's set (no-op if already picked today)
daily-wallpaper --force      pick again, avoiding today's set
daily-wallpaper --random     pick at random, without Claude
daily-wallpaper --dry-run    show the prompt and Claude's choice, change nothing
daily-wallpaper --log        recent picks, reasons and cost
```

## Setup

```
stow --no-folding daily-wallpaper
systemctl --user enable --now daily-wallpaper.timer
```

`--no-folding` keeps `~/.config/systemd/user` a real directory, so `systemctl --user enable`
doesn't write into this repo. If Claude is unavailable (Docker not running, not logged in), the
script picks at random.

The timer runs at 05:00, or at boot or resume if that time was missed.

## How it works

- `sets.json` lists the sets with a short description each; Claude only sees the descriptions.
  `{builtin}` is the extension's included image sets.
- Your own sets: put a folder of images in `~/.local/share/daily-wallpaper/sets/<name>/`, sorted
  by filename in day order starting at night (`0` = night, `9` = late evening), plus an optional
  `description.txt`. Folders without exactly 10 images are spread over the 10 periods.
- The chosen set is linked into `~/.local/share/daily-wallpaper/current/0.jpg`…`9.jpg`, and the
  extension's config points at that folder permanently, so the tracked extension config doesn't
  change daily.
- History: `~/.local/state/daily-wallpaper/history.jsonl`.
