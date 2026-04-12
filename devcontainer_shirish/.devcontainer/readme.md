# Summary /High level layout of the Ansible Development environment 

Do not change  any files in folder C:\data\workspace\devops_infra\ansible\dev_workspace
The master folder for any changes is [dev_container_shirish](C:\data\workspace\devops_infra\ansible\ansibleforbeginners_coursera\devcontainer_shirish)


## Starting the workspace and test containers

- Start podman
- launch VS Code workspace and open folder /workspace/ansibleforbeginners_coursera
- The VS code DEV container is the ansible host. This is where Ansible commands will be run from
- Now launch ansible target -> A container inside podman needs to be launched.


### Ansible target commands 

**Run from windows host where podman container is running**
 Replace image name "my-ansible-host2" with the latest image for ansible target.
Command starts the podman container that is to be used as target of ansible deployments
- -v share volume to share files between host and container, -p to map port 22 of container to 2222 on host machine, 
-  -it for interactive mode and my-ansible-host1 is the name of the podman image to be used for launching the container.
- -p 0.0.0.0 makes the port accessible from any network interface on the host machine, which is necessary for Ansible to connect to the container as a target host.

'''commands
podman run  -v C:\data\workspace\devops_infra\share_mounts\dev_container_copied_data:/shared/dev_container_copied_data -p 0.0.0.0:2222:22  -it my-ansible-host2


'''

### Ansible host commands

- Run the ping comamnd from Ansible server host to ping the target container.
- User and other details are set in inventory.ini file
- ch to the directory 
- ping the container .

``` bash
cd /workspace/ansibleforbeginners_coursera/ansible_quickstart 
ansible my_containers  -m   ping -i inventory.ini 

'''