#!/bin/bash
## ping the container 
ansible my_containers  -m   ping -i inventory.ini