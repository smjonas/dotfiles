# My configuration (Linux Mint 20.1)

## Fix crackling audio when Firefox is opened ([link](https://forums.linuxmint.com/viewtopic.php?t=288263)):
- run `xed admin:///etc/pulse/default.pa`
- replace the line `load-module module-udev-detect` with `load-module module-udev-detect tsched=0`
- then run `pulseaudio -k`

