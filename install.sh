#!/usr/bin/env bash

info() {
    clear
    echo -e "\033[1;34m##############################################################\033[1;37m"
    echo -e "\033[1;34m##\033[1;37m             \033[1;33mQlauncher Installer for \033[1;35mRaspbian\033[1;37m\033[1;34m             ##\033[1;37m"
    echo -e "\033[1;34m##############################################################\033[1;37m"
}

tools() {
	echo
	echo -e "\033[1;32m	[+] Updating Package...\033[1;37m"
	sudo apt update -y
	sudo apt upgrade -y
	sudo apt install curl net-tools nmap dmidecode lolcat -y
	sudo curl -o ql.tar.gz https://github.com/poseidon-network/qlauncher-linux/releases/latest/download/ql-linux.tar.gz
}

docker() {
	echo
	echo -e "\033[1;32m     [+] Installing Docker ...\033[1;37m"
	curl -sSL https://get.docker.com | sh
	sudo usermod -aG docker pi
}

ql() {
	echo
	echo -e "\033[1;32m     [+] Installing qlauncher...\033[1;37m"
	mkdir /home/pi/qlauncher
	tar -vxzf ql.tar.gz -C /home/pi/qlauncher
}

onboot() {
sudo cat > /etc/systemd/system/qlauncher.service << EOF
[Unit]
Description=qlauncher.service
[Service]
Type=simple
ExecStart=/home/pi/qlauncher/qlauncher.sh start
ExecStop=/home/pi/qlauncher/qlauncher.sh stop
RemainAfterExit=yes
[Install]
WantedBy=multi-user.target
EOF

}

reload() {
sudo systemctl daemon-reload
sudo systemctl enable qlauncher
}

script() {
sudo curl -o /usr/local/bin/Q https://raw.githubusercontent.com/jakues/ql-rpi/master/conf/Q
sudo chmod +x /usr/local/bin/Q
}

zram() {
#source : https://github.com/jmcerrejon/PiKISS/blob/master/scripts/tweaks/zram.sh
set -e
free -wth

enableZRAM() {
	echo -e "\nEnabling ZRAM...\n"
	cat <<\EOF >/tmp/zram
#!/bin/bash
CORES=$(nproc --all)
modprobe zram num_devices=${CORES}
swapoff -a
SIZE=$(( ($(free | grep -e "^Mem:" | awk '{print $2}') / ${CORES}) * 1024 ))
CORE=0
while [ ${CORE} -lt ${CORES} ]; do
  echo ${SIZE} > /sys/block/zram${CORE}/disksize
  mkswap /dev/zram${CORE} > /dev/null
  swapon -p 5 /dev/zram${CORE}
  (( CORE += 1 ))
done
EOF
	chmod +x /tmp/zram
	sudo mv /tmp/zram /etc/zram
	sudo /etc/zram
	if [ "$(grep -c zram /etc/rc.local)" -eq 0 ]; then
		sudo sed -i 's_^exit 0$_/etc/zram\nexit 0_' /etc/rc.local
	fi
}

removeZRAM() {
	echo -e "\nRemoving ZRAM...\n"
	CORES=$(nproc --all)
	CORE=0
	while [ ${CORE} -lt "${CORES}" ]; do
		sudo swapoff /dev/zram${CORE}
		((CORE += 1))
	done
	wait
	sleep .5
	sudo modprobe --remove zram
	sudo sed -i '/zram/d' /etc/rc.local
	sudo rm /etc/zram
	sudo /etc/init.d/dphys-swapfile stop >/dev/null
	sudo /etc/init.d/dphys-swapfile start >/dev/null
}

if [ -e /etc/zram ]; then
	echo
	read -p "ZRAM already installed. Remove it (y/N)? " response
	if [[ $response =~ [Yy] ]]; then
		removeZRAM
	fi
else
	echo
	read -p "ZRAM is not present. Enable it (y/N)? " response
	if [[ $response =~ [Yy] ]]; then
		enableZRAM
	fi
fi

echo
free -wth
echo
read -p "Done!. Press [Enter] to come back to the menu..."
#source : https://github.com/jmcerrejon/PiKISS/blob/master/scripts/tweaks/zram.sh
}

#Checking if user run on rpi
HOST_ARCH=$(uname -m)
if [ "${HOST_ARCH}" != "armv7l" ] && [ "${HOST_ARCH}" != "aarch64" ]; then
  echo "[!] This script is only intended to run on ARM devices."
  exit 1
fi

PI_MODEL=$(grep ^Model /proc/cpuinfo  | cut -d':' -f2- | sed 's/ R/R/')
if [[ "${PI_MODEL}" == *"Raspberry Pi"* ]]; then
  info
  tools
  docker
  ql
  onboot
  reload
  script
  clear
  zram
  clear
  Q --help
  Q --about
else
  echo "[!] This is not a Raspberry Pi. Quitting!"
  exit 1
fi
