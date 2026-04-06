#!/bin/sh
set -e

# Add Yarn GPG key to fix signature verification issues
curl -fsSL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -

apt-get update && apt-get install -y pipx
pipx ensurepath --global

# Install Ansible and Lint globally so they are in /usr/local/bin
PIPX_HOME=/opt/pipx PIPX_BIN_DIR=/usr/local/bin pipx install --include-deps ansible
PIPX_HOME=/opt/pipx PIPX_BIN_DIR=/usr/local/bin pipx install ansible-lint

# Clean up apt cache to reduce image size
apt-get clean && rm -rf /var/lib/apt/lists/*