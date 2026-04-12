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

# Copy SSH public key (supposed to be copied form the Ansible host )to mounted workspace directory with ENV_VAR SSH_KEYS_DIR or default to /workspace/dev_container_copied_data/ssh_keys if not set
SSH_KEYS_DIR="${SSH_KEYS_DIR:-/workspace/dev_container_copied_data/ssh_keys}"
echo "Copying SSH public key to mounted workspace at $SSH_KEYS_DIR..."
if [ -f /home/ansibleuser/.ssh/id_ed25519.pub ]; then
    mkdir -p "$SSH_KEYS_DIR"
    cp /home/ansibleuser/.ssh/id_ed25519.pub "$SSH_KEYS_DIR/ansible_public_key.pub"
    echo "SSH public key copied to $SSH_KEYS_DIR/ansible_public_key.pub"
else
    echo "Warning: SSH public key not found at /home/ansibleuser/.ssh/id_ed25519.pub"
fi

## Install curl 
RUN apt-get update && apt-get install -y curl && apt-get clean && rm -rf /var/lib/apt/lists/*    
