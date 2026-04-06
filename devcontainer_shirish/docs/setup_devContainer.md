# My Project

Detailed instructions on setup of this dev container file

## Customisations

1. Describe how to install.
2. Show one example command.

## Docker Image

### Configure ansible to avoid ssh errors 
Added section ##Configure ansible 

### Manul fix needed currently to cop ypublic key from dev container
chmod +777 dev_container_copied_data
cp /home/ansibleuser/.ssh/id_ed25519.pub /workspace/dev_container_copied_data/ssh_keys/ansible_public_key.pub


## Dev COntainer launch json 

- Explain the main config options.
- Give one simple config example.
