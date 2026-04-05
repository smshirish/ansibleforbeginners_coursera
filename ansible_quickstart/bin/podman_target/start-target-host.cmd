## This starts the podman container that is to be used as target of ansible deployments

podman run  -v C:\data\workspace\devops_infra\share_mounts:/shared -p 0.0.0.0:2222:22  -it my-ansible-host1

## building podman image with the following command:
podman build -f C:\data\workspace\devops_infra\ansible\ansibleforbeginners_coursera\ansible_quickstart\docker_images\Dockerfile-ansible-target1 . -t my-ansible-host1:latest