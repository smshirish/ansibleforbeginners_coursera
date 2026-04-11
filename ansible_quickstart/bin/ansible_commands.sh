#!/bin/bash


## Run the ping comamnd from Ansible server host to ping the target container.
## User and other details are set in inventory.ini file
## ping the container .
ansible my_containers  -m   ping -i inventory.ini 