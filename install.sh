#!/usr/bin/env bash

#///////////////////////////////////////
#//////////////////////////////////////
#////////qlauncher-installer//////////
#////////////////////////////////////
#///////////////////////////////////

ELF="echo -e"
COLOUR_RESET='\e[0m'
aCOLOUR=(
		'\e[1;33m'	# Yellow	    |
		'\e[1m'		# Bold white	|
		'\e[1;32m'	# Green		    |
		'\e[1;31m'  # Red		    |
	)

YELLOW_LINE=" ${aCOLOUR[0]}─────────────────────────────────────────────────────$COLOUR_RESET"
GREEN_BULLET=" ${aCOLOUR[2]}        [+]	$COLOUR_RESET"
GREEN_WARN=" ${aCOLOUR[2]}          [!] $COLOUR_RESET"
RED_WARN=" ${aCOLOUR[3]}            [!] $COLOUR_RESET"

#install requirements
tools() {
            	$ELF $YELLOW_LINE
		$ELF $GREEN_BULLET "${aCOLOUR[2]}Updating Package ..."
		$ELF $YELLOW_LINE

	             sudo apt-get update -qq -y ;  sudo apt-get upgrade -qq -y ; sudo apt-get autoremove -qq -y

	        $ELF $YELLOW_LINE
		$ELF $GREEN_BULLET "${aCOLOUR[2]}Installing Requirements ..."
		$ELF $YELLOW_LINE

	            sudo apt-get install wget nano net-tools nmap dmidecode lolcat -qq -y
	            wget https://git.io/JUEI8 -O ql.tar.gz
}

#check docker
is_docker_installed() {
 whereis docker | grep '/usr/bin/docker'
}

is_docker_enabled() {
 sudo systemctl is-enabled docker | grep disabled
}

#check docker group
docker_group() {
SOPO=$(env | grep -i user | cut -c 6-30)
 sudo usermod -aG $SOPO
}

check_docker() {
                if [[ $(id -u) == "1000" ]] ; then
                    $ELF $RED_WARN "${aCOLOUR[2]}Non root detected"
	                    if groups | grep docker ;  then
				$ELF $GREEN_WARN "${aCOLOUR[2]}Detected docker already on groups"
				$ELF $GREEN_WARN "${aCOLOUR[2]}OK"
	                    else
                    		$ELF $RED_WARN "${aCOLOUR[2]}Docker not in the groups"
				docker_group
			    fi
            	fi
}

#install docker
install_docker() {
	            $ELF $YELLOW_LINE
		    $ELF $GREEN_BULLET "${aCOLOUR[2]}Checking Docker ..."
		    $ELF $YELLOW_LINE

	                if is_docker_installed ; then
		                $ELF $GREEN_WARN "${aCOLOUR[2]}Docker Installed"
			                if is_docker_enabled ;  then
					    sudo systemctl enable docker
					fi
				check_docker
	                else
		                $ELF $RED_WARN "${aCOLOUR[2]}Docker not installed"
		                curl -sSL https://get.docker.com | sh
		                check_docker
	                fi
}

#install qlauncher
ql_install() {
        	$ELF $YELLOW_LINE
		$ELF $GREEN_BULLET "${aCOLOUR[2]} ..."
	    	$ELF $YELLOW_LINE

	        	sudo mkdir -p /etc/ql ;  sudo tar -vxzf ql.tar.gz -C /etc/ql ; rm ql.tar.gz
}

ql_onboot() {
sudo bash -c 'cat > /etc/systemd/system/qlauncher.service' << EOF
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

ql_reload() {
 sudo systemctl enable qlauncher ; sudo systemctl daemon-reload
}

ql_script() {
 sudo wget https://git.io/JUEkQ -O /usr/local/bin/Q ; sudo chmod +x /usr/local/bin/Q
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
  $ELF $RED_WARN "${aCOLOUR[2]}This script is only intended to run on ARM devices."
  exit 1
fi

    #kickoff
    PI_MODEL=$(cat /proc/device-tree/model)
        if [[ "${PI_MODEL}" == *"Raspberry Pi"* ]]; then
            tools ; install_docker ; ql_install ; ql_onboot ; ql_reload ; ql_script
        else
            $ELF $RED_WARN "${aCOLOUR[2]}This is not a Raspberry Pi"
        fi

#enable cgroup
if ls /boot/cmdline.txt > /dev/null 2>&1; then
    cgroup_raspbian
elif ls /boot/firmware/cmdline.txt > /dev/null 2>&1; then
    cgroup_ubuntu
else
    $ELF $RED_WARN "${aCOLOUR[2]}Cannot enable cgroup."
    $ELF $RED_WARN "${aCOLOUR[2]}Please enable it manually"
fi
