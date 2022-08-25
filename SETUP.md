# My configuration (Linux Mint 20.1)

## Fix crackling audio when Firefox is opened ([link](https://forums.linuxmint.com/viewtopic.php?t=288263)):
- run `xed admin:///etc/pulse/default.pa`
- replace the line `load-module module-udev-detect` with `load-module module-udev-detect tsched=0`
- then run `pulseaudio -k`

## Haskell development (with Neovim)
- Install ghcup (accept all): `curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh`
- Run `haskell-language-server-wrapper`:
  - If you see an error message like `could not find any haskell-language-server exe, looked for: haskell-language-server-8.10.6`, install a supported ghc version using `ghcup install ghc 8.10.5` (the `ghcup list` command should display `hls-powered` in the "Notes" column for this version).
