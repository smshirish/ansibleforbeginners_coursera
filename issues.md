#issues

List of issues during this project execution

## Workspace init issue

### Issue 1
Dev container cound not be loaded with following error :
ctivating feature 'alpine-bash'
./install.sh: 7: apk: not found
ERROR: Feature "alpine-bash" (ghcr.io/cirolosapio/devcontainers-features/alpine-
                                                                               -bash) failed to install! Look at the documentation at https://github.com/cirolos
                                                                               sapio/devcontainers-features/tree/main/src/alpine-bash for help tr


####  Resolution 
Updated install bash script to use correct docker build(removed ansible )


### Issue 2 
After fixing the scripts as above, Now I am getting following error.: [1/3] STEP 8/11: COPY post-create.sh /usr/local/bin/post-create.sh

--> 3a53ba230efd                                                                running runtime: exit status 127tmp/dev-container-

#### Cause
It looks like you’ve hit another "exit status 127" error, which in the world of Linux/Containers, almost always means a command was called that simply doesn't exist in the environment.

#### Resolution
Action: Update your devcontainer.json to only include the bare essentials.

To get your Ansible environment running immediately, we need to remove the non-essential "Features" that are conflicting with your base OS. The dot-config feature is failing because it's trying to execute scripts against a shell environment it doesn't recognize


### issue 3  Cant connect /ping from ansible control host
ansible my_containers  -m   ping -i inventory.ini -u ansible
Gives error:

target_container | UNREACHABLE! => {
    "changed": false,
    "msg": "Task failed: Failed to connect to the host via ssh: ssh: connect to host 127.0.0.1 port 2222: Connection refused",
    "unreachable": true
}

#### Resoultion:
#####  1. The Service Issue: SSH is not running

The Command Override: In container fundamentals, the CMD instruction in a Dockerfile sets the default process
. By adding tail -f /dev/null at the end of your podman run command, you have overridden the default command (which was likely /usr/sbin/sshd)

#### 



#### The Network Issue: "Double" Isolation
You are trying to connect from a VS Code devContainer to a Podman container. This creates a network "blindfold" effect
:
DevContainer Isolation: Your Ansible control node is inside its own container with its own Network Namespace
.
Target Container Isolation: Your target host is also in its own Network Namespace.
The Localhost Trap: When you map -p 2222:22, the port is bound to the Podman Host (your Windows/WSL environment)
. When you run Ansible inside the devContainer and tell it to look at 127.0.0.1, it looks at its own internal localhost, not the host machine where port 2222 is actually waiting

To find your Windows/WSL host IP address so that your Ansible DevContainer can communicate with your target container, you need to identify the IP of the virtual network bridge that connects your Windows host to the WSL2/Podman environment

Open a PowerShell or Command Prompt on your Windows host.
Type the command: ipconfig
Look for an entry titled "Ethernet adapter vEthernet (WSL)".
The IPv4 Address listed there (e.g., 172.x.x.x) is the IP of your Windows host as seen by the WSL/Podman network. This is the address you should use in your inventory.ini.

The ip address if the host , run ipconfig on windows host and find the swl2 address
Ethernet adapter vEthernet (WSL (Hyper-V firewall)):

   Connection-specific DNS Suffix  . :
   Link-local IPv6 Address . . . . . : fe80::14c0:8595:e247:b413%49
   IPv4 Address. . . . . . . . . . . : 172.17.80.1
   Subnet Mask . . . . . . . . . . . : 255.255.240.0
   Default Gateway . . . . . . . . . :


### Issue :Connection timing out 

After making above changes (find ip of wsl virtual network on podman host machine (windows)) and adding that to the ini file , still getting following error