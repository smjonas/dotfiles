# My configuration (Linux Mint 20.1)

## Fix crackling audio when Firefox is opened ([link](https://forums.linuxmint.com/viewtopic.php?t=288263)):
- run `xed admin:///etc/pulse/default.pa`
- replace the line `load-module module-udev-detect` with `load-module module-udev-detect tsched=0`
- then run `pulseaudio -k`

## Haskell development (with Neovim)
### Install stack
```bash
curl -sSL https://get.haskellstack.org/ | sh
```
### Install hls (haskell language server)
1. Go to https://github.com/haskell/haskell-language-server/releases/latest.
2. Download `haskell-language-server-wrapper-Linux.gz` and a specific version of hls, e.g. `haskell-language-server-Linux-8.10.5.gz`.
3. Unpack them and make the wrapper file executable: `chmod +x haskell-language-server-wrapper`.
4. Make sure the folder where you placed the wrapper is on your path (`echo $PATH`).



