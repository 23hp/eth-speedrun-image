#!/bin/bash
set -e
HK=/home/vscode/.ssh-host
mkdir -p "$HK" && chmod 700 "$HK"
[ -f "$HK/ssh_host_ed25519_key" ] || ssh-keygen -q -t ed25519 -N '' -f "$HK/ssh_host_ed25519_key"

# StrictModes 要求公钥目录归 root 且不可被他人写入
sudo install -d -m 755 -o root -g root /etc/ssh/authorized_keys
sudo install -m 644 -o root -g root /authkeys-src/node /etc/ssh/authorized_keys/vscode

# 后台装包,不阻塞 sshd;flock 防止重复执行
( flock -n 9 || exit 0; dev-bootstrap ) 9>/tmp/bootstrap.lock >> "$HOME/.bootstrap.log" 2>&1 &

env | grep -E '^(KUBERNETES_|POD_)' | sudo tee -a /etc/environment >/dev/null

sudo mkdir -p /run/sshd
exec sudo /usr/sbin/sshd -D -e