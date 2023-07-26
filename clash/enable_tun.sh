#!/bin/bash
echo -e "Add dev..."
sudo ip tuntap add mode tun dev tun-fclash
sudo ip addr add 198.18.0.1/15 dev tun-fclash
sudo ip link set dev tun-fclash up
# Configure the default route table with different metrics. Let's say the primary interface is eth0 and gateway is 172.17.0.1.
echo -e "Configuring routes..."
sudo ip route del default
sudo ip route add default via 198.18.0.1 dev tun-fclash