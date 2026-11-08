# Typing Lab

Practice and benchmark tool for retraining on the Piantor (Colemak-DH with home-row mods), compared against QWERTY.

```sh
~/dotfiles/typing-lab/server.py      # serves http://127.0.0.1:8765 and opens the browser
```

- **Practice**: about 19 minutes a day, built from your own data: common words you type slowly, keys you mix up (wrong keys stop you), slow letters, real sentences, and two bursts at 110% of your speed.
- **Test**: the weekly benchmark (60 s English words, on each keyboard).
- **Compare**: Piantor vs QWERTY by letter, word, motion and error type.

Every session is saved as JSON in `data/sessions/` with the raw keystrokes (`ks`), timestamps (`ts`) and key hold times (`du`).
The keyboard is detected automatically: on the Piantor, home-row-mod keys and Space type on release, so they show ~0 ms hold time.

`words.js` holds the English/German frequency lists (generated with the `wordfreq` package).
Without the server (opening `index.html` directly) the page falls back to browser storage.
