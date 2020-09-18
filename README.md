<h1 align="center">Automatic Installation Qlauncher for Raspberry Pi</h1>

This scripts automates the installation process for [Qlauncher](https://github.com/poseidon-network/qlauncher-linux).
It automatically downloads and installs the following packages:

* docker
* net-tools
* lolcat 😋
* Qlauncher (Latest)

# [ Prerequisites ]

The installation scripts require the following:

* The Raspberry Pi 2B, 2B+, 3B, 3B+ and 4B with operating system [Raspberry Pi OS](https://downloads.raspberrypi.org/raspios_lite_armhf_latest) or [Ubuntu server 32 bit](https://ubuntu.com/download/raspberry-pi).
* Manually open port via your router

# [ Install ]

  * First do this command to one hit installing qlauncher
    * `curl -sSL https://raw.githubusercontent.com/jakues/ql-rpi/master/install.sh | bash`
  * Then reboot raspberry
    * `sudo reboot`
  * Dont forget open port `443, 32440-32449` via your router 

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
