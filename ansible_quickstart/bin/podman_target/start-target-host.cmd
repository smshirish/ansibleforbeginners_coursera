## building podman image with the following command:
podman build --quiet --log-level error -f C:\data\workspace\devops_infra\ansible\ansibleforbeginners_coursera\ansible_quickstart\docker_images\Dockerfile-ansible-target1 . -t my-ansible-host2:latest

## This starts the podman container that is to be used as target of ansible deployments
## -v share volume to share files between host and container, -p to map port 22 of container to 2222 on host machine, -it for interactive mode and my-ansible-host1 is the name of the podman image to be used for launching the container.
## -p 0.0.0.0 makes the port accessible from any network interface on the host machine, which is necessary for Ansible to connect to the container as a target host.
podman run  -v C:\data\workspace\devops_infra\share_mounts:/shared -p 0.0.0.0:2222:22  -it my-ansible-host2