#!/bin/bash
# Wazuh SIEM - User Data Script
# Installs Docker and deploys Wazuh single-node via Docker Compose

set -e

# System update
yum update -y
yum install -y docker git curl wget

# Start and enable Docker
systemctl start docker
systemctl enable docker

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Set vm.max_map_count for Elasticsearch
echo "vm.max_map_count=262144" >> /etc/sysctl.conf
sysctl -w vm.max_map_count=262144

# Create Wazuh directory
mkdir -p /opt/wazuh
cd /opt/wazuh

# Download Wazuh Docker Compose
curl -so docker-compose.yml https://raw.githubusercontent.com/wazuh/wazuh-docker/v4.9.2/single-node/docker-compose.yml

# Generate SSL certificates
git clone https://github.com/wazuh/wazuh-docker.git -b v4.9.2 --depth=1
cd wazuh-docker/single-node
docker-compose -f generate-indexer-certs.yml run --rm generator
cd /opt/wazuh

# Start Wazuh
docker-compose up -d

# Log completion
echo "Wazuh installation complete" >> /var/log/soar-setup.log
