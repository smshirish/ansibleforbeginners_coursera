#!/bin/bash

# Create a directory for your global ansible config if needed
RUN mkdir -p /etc/ansible

# Using '>>' to append just in case it exists
cat <<EOF >> /etc/ansible/ansible.cfg
[defaults]
host_key_checking = False
EOF


# Set the environment variable so Ansible always finds it
ENV ANSIBLE_CONFIG=/etc/ansible/ansible.cfg

# (Optional) You can even 'copy' a local config file into the image
# COPY my_custom_ansible.cfg /etc/ansible/ansible.cfg