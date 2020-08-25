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
	echo -e "\033[1;32m     [+] Installing Requirements...\033[1;37m"
	sudo apt install curl wget nano net-tools nmap dmidecode lolcat -y > sudo /dev/null 2>&1 &
	wget https://github.com/poseidon-network/qlauncher-linux/releases/latest/download/ql-linux.tar.gz -O ql.tar.gz > sudo /dev/null 2>&1 &
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
	sudo mkdir /etc/ql > sudo /dev/null 2>&1 &
	sudo tar -vxzf ql.tar.gz -C /etc/ql > sudo /dev/null 2>&1 &
	rm ql.tar.gz
}

onboot() {
sudo cat > /etc/systemd/system/qlauncher.service << EOF
[Unit]
Description=qlauncher.service
[Service]
Type=simple
ExecStart=/etc/ql/qlauncher.sh start
ExecStop=/etc/ql/qlauncher.sh stop
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

cgroup_raspbian() {
CMDLINE=/boot/cmdline.txt
sudo sed -i -e 's/rootwait/cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1 rootwait/' $CMDLINE
}

cgroup_ubuntu() {
CMDLINE=/boot/firmware/cmdline.txt
sudo sed -i -e 's/rootwait/cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1 rootwait/' $CMDLINE
}

#Checking if user run on rpi
HOST_ARCH=$(uname -m)
if [ "${HOST_ARCH}" != "armv7l" ]; then
  echo -e "\033[1;31m     [!] This script is only intended to run on ARM devices."
  exit 1
fi

#shoot
PI_MODEL=$(cat /proc/device-tree/model)
if [[ "${PI_MODEL}" == *"Raspberry Pi 4"* ]]; then
  info
  tools
  docker
  ql
  onboot
  reload
  script
  clear
  Q --help
  Q --about
else
  echo -e "\033[1;31m     [!] This is not a Raspberry Pi 4."
  exit 1
fi

#enable cgroup
if ls /boot/cmdline.txt > /dev/null 2>&1; then
    cgroup_raspbian
elif ls /boot/firmware/cmdline.txt > /dev/null 2>&1; then
    cgroup_ubuntu
else
    echo -e "\033[1;33m     [!] Cannot enable cgroup please enable it manually"
fi
