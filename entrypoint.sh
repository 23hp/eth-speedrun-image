#!/bin/bash
set -e
HK=/home/node/.ssh-host
mkdir -p "$HK" && chmod 700 "$HK"
[ -f "$HK/ssh_host_ed25519_key" ] || ssh-keygen -q -t ed25519 -N '' -f "$HK/ssh_host_ed25519_key"
sudo mkdir -p /run/sshd
exec sudo /usr/sbin/sshd -D -e