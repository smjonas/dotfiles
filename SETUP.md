# My configuration (Linux Mint)

## Auto-mount with sshfs
`sudoedit /etc/fstab`:
```
user@servername1:/directory/ /mnt/s1/ fuse.sshfs noauto,x-systemd.automount,_netdev,reconnect,identityfile=/home/jonas/.ssh/id,allow_other,default_permissions 0 0
user@servername2:/directory/ /mnt/s2/ fuse.sshfs noauto,x-systemd.automount,_netdev,reconnect,identityfile=/home/jonas/.ssh/id,allow_other,default_permissions 0 0
```

## Fix crackling audio when Firefox is opened ([link](https://forums.linuxmint.com/viewtopic.php?t=288263)):
- run `xed admin:///etc/pulse/default.pa`
- replace the line `load-module module-udev-detect` with `load-module module-udev-detect tsched=0`
- then run `pulseaudio -k`

## Haskell development (with Neovim)
- Install ghcup (accept all): `curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh`
- Run `haskell-language-server-wrapper`:
  - If you see an error message like `could not find any haskell-language-server exe, looked for: haskell-language-server-8.10.6`, install a supported ghc version using `ghcup install ghc 8.10.5` (the `ghcup list` command should display `hls-powered` in the "Notes" column for this version).
