#!/bin/bash
## ping the container . User etc is set in inventory.ini file 
ansible my_containers  -m   ping -i inventory.ini 