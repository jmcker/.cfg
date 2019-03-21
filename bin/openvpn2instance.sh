#!/bin/bash

FILE_NAME="server2"
DEV_NAME="tun"
NEW_PORT=47774
NEW_SUBNET="10.67.13.0"
PROTECTED_SUBNET="192.168.1.0"
NEW_MASK="255.255.255.0"
OVPN_OUTPUT="/home/pi/ovpns"

if [ "$(whoami)" != "root" ]; then
    echo "Script requires root for access to /etc/openvpn, iptables, and systemctl."
    echo
    echo "Try: sudo $0"
    echo
    exit 1
fi

# Add a client via PiVPN and modify it for the secondary VPN
if [ "$1" == "add" ]; then
    read -p "Enter a Name for the Client: " CLIENT_NAME
    pivpn add -n ${CLIENT_NAME}

    if [ -f ${OVPN_OUTPUT}/${CLIENT_NAME}.ovpn ]; then
        echo "Updating Client remote port to ${NEW_PORT}..."
        sed -i "s/remote \(.*\) [0-9]*/remote \1 ${NEW_PORT}/" ${OVPN_OUTPUT}/${CLIENT_NAME}.ovpn
        echo "Done."
        exit 0
    else
        echo
        echo "Could not find ${OVPN_OUTPUT}/${CLIENT_NAME}.ovpn."
        echo "PiVPN may have failed."
        echo
        exit 1
    fi
fi

if [ "$(whoami)" != "root" ]; then
    echo "Script requires root for access to /etc/openvpn, iptables, and systemctl."
    echo
    echo "Try: sudo $0"
    echo
    exit 1
fi

if [ -f /etc/openvpn/${FILE_NAME}.conf ]; then
    echo "/etc/openvpn/${FILE_NAME}.conf already exists."
    echo
    exit 1
fi

cd /etc/openvpn
cp server.conf ${FILE_NAME}.conf

# Change the device name
echo "Updating device basename to ${DEV_NAME}..."
sed -i "s/dev .*/dev ${DEV_NAME}/" ${FILE_NAME}.conf

# Change the port
echo "Updating VPN port to ${NEW_PORT}..."
sed -i "s/port [0-9]*/port ${NEW_PORT}/" ${FILE_NAME}.conf
echo "Done."

# Update subnet
echo "Updating VPN subnet to ${NEW_SUBNET} ${NEW_MASK}..."
sed -i "s/server \([0-9]\{1,3\}\.\)\{3\}[0-9]\{1,3\} .*/server ${NEW_SUBNET} ${NEW_MASK}/" ${FILE_NAME}.conf
echo "Done."

# Allow port
# Only if using UFW
#ufw allow ${NEW_PORT}/udp

# Enable autostart ?
echo "Starting openvpn@${FILE_NAME}.service..."
systemctl enable openvpn@${FILE_NAME}.service
systemctl restart openvpn@${FILE_NAME}.service
echo "Done."

# Update iptable rules (from /opt/pivpn/fix_iptables.sh)
IPV4DEV=$(ip route get 8.8.8.8 | awk '{for(i=1;i<=NF;i++)if($i~/dev/)print $(i+1)}')
iptables -t nat -A POSTROUTING -s ${NEW_SUBNET}/24 -o ${IPV4DEV} -j MASQUERADE

# Reject traffic to any IP in the 192.168.X.X range
# Grab the dev name from ip route since it might have gained a number (i.e. tun1)
VPNDEV=$(ip route get ${NEW_SUBNET} | awk '{for(i=1;i<=NF;i++)if($i~/dev/)print $(i+1)}')
echo "Adding iptable rules to protect ${PROTECTED_SUBNET}/16 from traffic on ${VPNDEV}/${NEW_SUBNET}..."
iptables -t raw -A PREROUTING -i ${VPNDEV} -s ${NEW_SUBNET}/24 -d ${PROTECTED_SUBNET}/16 -j DROP

iptables-save > /etc/iptables/rules.v4
iptables-restore < /etc/iptables/rules.v4
echo "Done."
