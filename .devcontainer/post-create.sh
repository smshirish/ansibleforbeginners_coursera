#!/bin/bash
set -e

if [ ! -z "$PYTHON_PACKAGES" ]; then
    echo "Injecting Python packages into pipx Ansible environment..."
    pipx inject ansible $(echo $PYTHON_PACKAGES | tr ',' ' ')
fi

if [ ! -z "$ANSIBLE_COLLECTIONS" ]; then
    echo "Installing Ansible collections..."
    echo "collections:" > /tmp/requirements.yml
    for c in ${ANSIBLE_COLLECTIONS//,/ }; do
        echo "  - name: $c" >> /tmp/requirements.yml
    done
    ansible-galaxy collection install -r /tmp/requirements.yml
fi

# Cleanup environment variables
unset PYTHON_PACKAGES
unset ANSIBLE_COLLECTIONS

# Copy SSH public key to mounted workspace directory
echo "Copying SSH public key to mounted workspace..."
if [ -f /home/ansibleuser/.ssh/id_ed25519.pub ]; then
    mkdir -p /workspace/dev_container_copied_data/ssh_keys
    cp /home/ansibleuser/.ssh/id_ed25519.pub /workspace/dev_container_copied_data/ssh_keys/ansible_public_key.pub
    echo "SSH public key copied to /workspace/dev_container_copied_data/ssh_keys/ansible_public_key.pub"
else
    echo "Warning: SSH public key not found at /home/ansibleuser/.ssh/id_ed25519.pub"
fi