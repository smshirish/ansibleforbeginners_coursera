FROM docker.io/library/ubuntu:24.04

RUN apt-get update && \
    apt-get install -y openssh-server python3 sudo && \
    mkdir /var/run/sshd && \
    useradd -m ansible && echo "ansible:ansible" | chpasswd && \
    mkdir -p /home/ansible/.ssh && \
    chown -R ansible:ansible /home/ansible/.ssh

EXPOSE 22
CMD ["/usr/sbin/sshd","-D","-e"]