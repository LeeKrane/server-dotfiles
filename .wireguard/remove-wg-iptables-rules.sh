#!/bin/bash
iptables -D INPUT -i wg0 -j ACCEPT
iptables -D FORWARD -i eth0 -o wg0 -j ACCEPT
iptables -D FORWARD -i wg0 -o eth0 -j ACCEPT
iptables -D INPUT -i eth0 -p udp --dport 13231 -j ACCEPT

