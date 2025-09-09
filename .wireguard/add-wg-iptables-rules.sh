#!/bin/bash
iptables -A INPUT -i eth0 -p udp --dport 13231 -j ACCEPT
iptables -A FORWARD -i wg0 -o eth0 -j ACCEPT
iptables -A FORWARD -i eth0 -o wg0 -j ACCEPT
iptables -A INPUT -i wg0 -j ACCEPT

