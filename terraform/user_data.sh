#!/bin/bash
set -e

# Update and basic tools
apt-get update -y
apt-get upgrade -y
apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release software-properties-common rsync

# Docker install (official repo)
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io

# Add admin user to docker group
usermod -aG docker ubuntu

# Docker Compose v2 as plugin
mkdir -p /usr/libexec/docker/cli-plugins
curl -SL https://github.com/docker/compose/releases/download/v2.40.3/docker-compose-linux-armv7 -o /usr/libexec/docker/cli-plugins/docker-compose
chmod +x /usr/libexec/docker/cli-plugins/docker-compose

# Enable and start docker
systemctl enable docker rsync
systemctl start docker rsync

