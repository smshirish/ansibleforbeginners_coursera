## This starts the podman container that is to be used as target of ansible deployments

podman run  -v C:\data\workspace\devops_infra\share_mounts:/shared -p 2222:22  -d my-ansible-host1