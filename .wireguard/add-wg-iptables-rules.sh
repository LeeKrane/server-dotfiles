#!/bin/bash
# Allow incoming WireGuard UDP traffic on the public interface (eth0)
iptables -A INPUT -i eth0 -p udp --dport 13231 -j ACCEPT
# Allow all traffic from the WireGuard interface (wg0) to be forwarded
iptables -A FORWARD -i wg0 -j ACCEPT
# Allow traffic from the public interface (eth0) to be forwarded to the WireGuard interface (wg0)
iptables -A FORWARD -o wg0 -j ACCEPT
# Allow all incoming traffic on the WireGuard interface (wg0) to the server itself
iptables -A INPUT -i wg0 -j ACCEPT
