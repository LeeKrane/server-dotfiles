#!/bin/bash
iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
iptables -D INPUT -i wg0 -j ACCEPT
iptables -D FORWARD -o wg0 -j ACCEPT
iptables -D FORWARD -i wg0 -j ACCEPT
iptables -D INPUT -i eth0 -p udp --dport 13231 -j ACCEPT
