<h1 align="center">Automatic Installation Qlauncher for Raspberry Pi</h1>

This scripts automates the installation process for [Qlauncher](https://github.com/poseidon-network/qlauncher-linux).
It automatically downloads and installs the following packages:

* docker
* net-tools
* lolcat 😋
* Qlauncher (Latest)

# [ Prerequisites ]

The installation scripts require the following:

* The Raspberry Pi 4B with operating system Raspberry Pi OS.
* Run as pi user
* Manually open port via your router

# [ Install ]

  * First do this command to install qlauncher
    * `curl -sSL https://raw.githubusercontent.com/jakues/ql-rpi/master/install.sh | bash`
  * Then open `/boot/cmdline.txt`
    * `sudo nano /boot/cmdline.txt`
  * Add this text after `fsck.repair=yes` and before `rootwait`
    * `cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1`
  * Save it `CTRL+X`
  * Then reboot raspberry to see effects
    * `sudo reboot`

  * P.S
    * You must add `cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1` to the end of the existing line. if you add it at the bottom of file in a new line it doesn't work.
    * If you using the ubuntu server on raspberry pi, you must modify `/boot/firmware/nobtcmd.txt` instead of `/boot/cmdline.txt`

# [ Uninstall ]

use this command to uninstall Qlauncher
```
coming soon
```


# [ Script only ]

if you just done install Qlauncher with [this instruction](https://github.com/poseidon-network/qlauncher-linux) you can use this script for easily control Qlauncher but require [lolcat installed](https://github.com/busyloop/lolcat)
```
sudo curl -o /usr/local/bin/Q https://raw.githubusercontent.com/jakues/ql-rpi/master/conf/Q
sudo chmod +x /usr/local/bin/Q
Q --help
```
