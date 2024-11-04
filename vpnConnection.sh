#!/bin/bash
#autor: Unkn0wn1122
#helper: liandd

#Colours
greenColour="\e[0;32m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m"
blueColour="\e[0;34m"
yellowColour="\e[0;33m"
purpleColour="\e[0;35m"
turquoiseColour="\e[0;36m"
grayColour="\e[0;37m"

function ctrl_c() {
	echo -e "\n${redColour}[!] Bye...${endColour}\n"
	tput cnorm && exit 1
}

# Ctrl + c
trap ctrl_c INT

function helpPanel() {
	echo -e "\n\n${grayColour}Usage:${endColour} ${yellowColour}./vpnConnection.sh < -c >, < -d >, < -h >${endColour}

    ${purpleColour}-c${endColour} ${yellowColour}[*]${endColour} ${grayColour}Start Connection with the vpn${endColour}

    ${purpleColour}-d${endColour} ${yellowColour}[*]${endColour} ${grayColour}Close Connection${endColour}

    ${purpleColour}-h${endColour} ${yellowColour}[*]${endColour} ${grayColour}This help panel${endColour}\n\n"
}

function checkerForTun() {
	echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Starting checker for tun Interface...${endColour}"
	ip_check=$(ip -4 -o addr show | grep 'tun' | grep '10\.')
	if [[ -n "$ip_check" ]]; then
    		echo -e "\n${redColour}[!] There is a VPN instance already running.${endColour}\n"
    		exit 1
	else
  		checker=$(ip link | grep 'tun')
  		if [[ "$?" -eq 1 ]]; then
    			echo -e "\n${redColour}[!] There is no tun Interface available..${endColour}\n\n${yellowColour}[!]${endColour} ${grayColour}Setting${endColour} ${blueColour}tun0${endColour} ${grayColour}Interface on...${endColour}"
    			createTUN=$(sudo ip tuntap add mode tun tun0)
    			psId3=$!
    			wait $psId3
  		else
    			echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Checker done...${endColour}"
  		fi
	fi
}

function connect() {
  	checkerForTun
	ovpnFile=$(find / -type f -name 'lab_*.ovpn' 2>/dev/null &)
	psId1=$!
	wait $psId1
  	command -v openvpn >/dev/null 2>&1 || {
    		echo -e "\n${redColour}[!] I requiere "openvpn" package...\n${endColour}";
    		echo -e "${yellowColour}[*]${endColour} ${grayColour}Do you want to install this package? -> ${endColour}${grayColour}"${endColour}${redColour}openvpn${endColour}${grayColour}"${endColour}"
    		read -r -p "Are you sure? [y/N] :" response
    		response=${response,,}
    		if [[ "$response" =~ ^(yes|y)$ ]]; then
      			if [[ -x "$(command -v apt)" ]]; then
        			echo -e "\n${blueColour}[+] installing...${endColour}"
        			installed=$(sudo apt install openvpn -y)
        			psId2=$!
        			wait $psId2
        			echo -e "\n${purpleColour}[*] Succesfully installed in debian based!${endColour}\n"
				sleep 1.9
				clear
      			elif [[ -x "$(command -v pacman)" ]]; then
        			echo -e "\n${blueColour}[+] installing...${endColour}"
        			installed=$(sudo pacman -Sy openvpn)
        			ps2Id=$!
        			wait $psId2
        			echo -e "\n${purpleColour}[*] Succesfully installed in arch based!${endColour}\n"
				sleep 1.9
				clear
      			fi
    		else
      			echo -e "\n${redColour}[!] No package installed... aborting!\n ${endColour}"
      			exit 1
    	fi
  	}
	echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Starting connection....${endColour}"
	sleep 1.5
	check=$(
		sudo openvpn --config $ovpnFile --dev tun0 --daemon >/dev/null 2>&1
		echo $?
	)
	if [ "$check" -eq 0 ]; then
		echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Established connection${endColour}\n"
	else
		echo -e "\n${redColour}[!] Connection could not be established${endColour}\n"
	fi
}

function disconnect() {
	psId=$(pgrep openvpn 2>/dev/null)
	check=$(
		sudo kill $psId 2>/dev/null
		echo $?
	)
	if [ "$check" -eq 0 ]; then
		echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Turning off connection....${endColour}\n"
		sleep 1.5
	else
		echo -e "\n${redColour}[!] There is not an openvpn process running...${endColour}\n"
	fi
}

declare -i parameter_counter=0

while getopts "cdh:" arg; do
	case $arg in
	c) let parameter_counter+=1 ;;
	d) let parameter_counter+=2 ;;
	h) let parameter_counter+=3 ;;
	esac
done

if [ $parameter_counter -eq 1 ]; then
	connect
elif [ $parameter_counter -eq 2 ]; then
	disconnect
elif [ $parameter_counter -eq 3 ]; then
	helpPanel
else
	helpPanel
fi
