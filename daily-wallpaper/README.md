# daily-wallpaper

Every morning Claude (Sonnet 5.5) picks one image set for the
[Cinnamon Dynamic Wallpaper](https://github.com/TobiZog/cinnamon-dynamic-wallpaper) extension. It
looks at the Karlsruhe forecast (Open-Meteo), the season, the weekday and the last 14 picks. The
extension keeps switching images by time of day. One API call costs about $0.01, so roughly
$0.40 a month.

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
echo 'ANTHROPIC_API_KEY=sk-ant-...' > ~/.config/daily-wallpaper/env && chmod 600 ~/.config/daily-wallpaper/env
systemctl --user enable --now daily-wallpaper.timer
```

`--no-folding` keeps `~/.config/systemd/user` a real directory, so `systemctl --user enable`
doesn't write into this repo. Without the env file, the SDK's usual credential lookup applies
(`ANTHROPIC_API_KEY` or an `ant auth login` profile). If Claude is unavailable, the script
picks at random. Needs `uv`.

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
