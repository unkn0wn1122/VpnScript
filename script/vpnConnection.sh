#!/bin/bash
#autor: Unkn0wn1122

option=$1

if [[ $option == "-h" || $option == "--help" || $option == "" || $option == "--h" ]];then
    echo "Usage: ./vpnConnection.sh < -on > or < -off >

    -on [*]Start Connection with the vpn 

    -off [*]Close connection"
fi

case $option in

    "-on")#case1.
    check=$(sudo openvpn --config /home/unknown/Downloads/lab_unkn0wn1122.ovpn --daemon > /dev/null 2>&1)#Change this with the route to your path.
    echo "[*]Starting connection..."
    sleep 1
    if [ $? == 0 ]; then
        echo "!Connection Succesfully! :)"
    else
        echo "!Connection Error! :("
    fi 
    ;;#case1.

    "-off")#case2.
    process_code=$(pgrep openvpn)
    sudo kill $process_code
    echo "[*]Shutting down connection..."
    sleep 1
    echo "Bye"
    ;;#case2.

esac
