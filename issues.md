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

After making above changes (find ip of wsl virtual network on podman host machine (windows)) and adding that to the ini file , still cant connect .Now get timepout error 

On podmad host side, the container is not visible even though the container starts corrected.

#### root cause
checked logs with podmain logs  containd_id  

Logs show now error: Container started 

COntainer is starting and exiting.

Why is container exiting:
The ssh process command makes sure that container will not stop as sshd is run in foregorund 

CMD ["/usr/sbin/sshd","-D","-e"]

So ssh process must be failing. 

RU container in foreground (with -it flag instead of -d flag ) and see error happening

-- podman command 
C:\data\workspace\devops_infra\ansible\ansibleforbeginners_coursera\ansible_quickstart\docker_images>podman run  -v C:\data\workspace\devops_infra\share_mounts:/shared -p 2222:22  -it my-ansible-host1


Unable to load host key: /etc/ssh/ssh_host_rsa_key
Unable to load host key: /etc/ssh/ssh_host_ecdsa_key
Unable to load host key: /etc/ssh/ssh_host_ed25519_key
sshd: no hostkeys available -- exiting.


### Issue X -> Still cant connect 

#### Error as below
The issue with ssh is fixed and I can see that podman starts the container successfully : C:\data\workspace\devops_infra\ansible\ansibleforbeginners_coursera\ansible_quickstart\docker_images>podman run  -v C:\data\workspace\devops_infra\share_mounts:/shared -p 2222:22  -it my-ansible-host1
Server listening on 0.0.0.0 port 22.
Server listening on :: port 22.     But I still cant connect and get following error: "msg": "Task failed: Failed to connect to the host via ssh: ssh: connect to host 172.17.80.1 port 2222: Connection timed out",  ...Provide me step by step instructions to trouble shoot this issue

The "Connection timed out" error indicates that the network packet sent from your Ansible DevContainer is getting "lost" or blocked before it can reach the target container through the host's mapped port (2222). Because containers use Network Namespaces to create a "blindfold" around their network stack, they cannot see each other’s internal traffic or the host's localhost without specific routing
.
Here are the step-by-step instructions to troubleshoot and fix this connectivity issue:
Step 1: Verify the Target is Reachable from the Windows Host
Before troubleshooting the container-to-container path, ensure the port mapping is working on your physical machine.
Open PowerShell on your Windows host.
Run: ssh -p 2222 ansible@127.0.0.1

##### Step 1 works

2: Check Podman's Binding Address
When you ran podman run -p 2222:22, Podman likely bound the port to the localhost of the WSL VM. Because your Dev Container and your target container are in separate Network Namespaces, they are "blindfolded" from each other's local traffic
.
The Issue: If Podman is only listening on 127.0.0.1 inside the WSL VM, it may not be reachable via the host IP 172.17.80.1.
The Fix: You can explicitly tell Podman to listen on all interfaces by using 0.0.0.0 in your run command: podman run -p 0.0.0.0:2222:22 -d my-ansible-host1
.


### After all issues with connection resolved , Ansible issue 

[ERROR]: Task failed: Action failed: Module result deserialization failed: No start of json char found

#### Analysis (gemini )
This error, "Module result deserialization failed: No start of json char found," typically means that while Ansible successfully connected to your target container via SSH, it received unexpected text (like a login banner, an error message, or a warning) instead of the clean JSON data it expects from a module execution


##### Likely causes

###### 1:Missing or Misconfigured Python Path

Ansible modules are Python scripts that run on the target host. Your Dockerfile correctly installed python3, but Ansible often looks for a binary simply named python (which usually refers to the older Python 2.7)
.
The Issue: If /usr/bin/python does not exist, the target might be returning a "command not found" error in plain text, which isn't JSON.
The Fix: Explicitly tell Ansible to use python3 in your inventory.ini:

How to confirm:
To confirm if the issue is Python-related, try running the raw module. The raw module sends a direct SSH command without requiring Python on the target
.
Run: ansible my_containers -m raw -a "whoami" -i inventory.ini
Interpretation: If this works but -m ping fails, the issue is definitely with the Python interpreter or the environment's ability to run Python scripts


RAn command as below and that works
ansible my_containers  -m   raw  -a "whoami" -i inventory.ini  -k 

After running raw command instead of ping, I get following (is this success or error case ?):SSH password:
target_container | CHANGED | rc=0 >>
ansible
Shared connection to 172.17.80.1 closed.


This is a success case.
The output you received confirms that your Ansible control node successfully connected to the target container and executed a command. Here is the breakdown of why this is a positive result:
rc=0: In Linux and container operations, a Return Code of 0 is the standard indicator for success
. Any other number would indicate an error.
CHANGED: For the raw module, Ansible always reports a "changed" state because it cannot determine if the command altered the system's state; it simply knows the command was delivered and executed.
ansible: This is the "standard output" of the command you ran (likely whoami). It proves that you are logged into the container as the ansible user you created in your Dockerfile [Conversation History].
Shared connection closed: This is a normal message indicating the SSH session ended successfully after the task was completed.
What this means for your troubleshooting
Since the raw module worked but the standard ping module failed previously with a "deserialization" error, you have successfully isolated the problem:
Connectivity is Fixed: Your Port Forwarding, Windows Firewall rules, and WSL Network Bridge are all now functioning correctly
.
SSH is Fixed: Your Host Keys are working, and your Authentication (password or key) is accepted [124, Conversation History].
The Remaining Issue is Python: Standard Ansible modules (like ping) require Python to be present on the target to format their responses as JSON [Conversation History]. The raw module does not require Python, which is why it succeeded where the others failed.
Next Step: To get the standard ping module working, ensure your inventory.ini specifies the correct Python path:
ansible_python_interpreter=/usr/bin/python3

Since the raw module worked earlier but the ping module is still failing with a "Module result deserialization failed" error, we know the SSH connection is healthy, but the data returning from the target is being "polluted" by non-JSON text.
Even if the python3 path is correct in your inventory.ini, several other environmental factors could be injecting text into the SSH stream and breaking Ansible’s parser. Here is what else could be wrong and how to troubleshoot it:
1. Shell "Noise" from .bashrc or .profile
In container environments, if the ansible user's shell configuration files (like /home/ansible/.bashrc or .profile) contain echo or print statements, that text is sent back during every SSH session.
The Problem: Ansible expects the target to return only JSON. If the target returns "Hello User! {...", the JSON parser fails because it doesn't see { as the first character.
The Fix: Log into your target container and ensure that .bashrc, .profile, or /etc/motd are not printing any "Welcome" banners or status messages
.
2. Check the Verbose Output (-vvv)
The most effective way to solve this is to see exactly what "noise" is being returned.
Action: Run your ping command with triple verbosity: ansible target_container -m ping -i inventory.ini -vvv
What to look for: Look for the section labeled stdout. It will show you the exact string that caused the failure. If you see an error like sh: 1: /usr/bin/python3: not found or a system warning, that is your culprit.
3. Sudo/Become Interference
If your command or playbook includes become: yes, Ansible is trying to escalate privileges to root.
The Problem: If the ansible user requires a password for sudo, but you haven't provided it or configured NOPASSWD, the target container will print [sudo] password for ansible:.
The Fix: Ensure your Dockerfile includes the following to allow the user to run modules without a prompt: RUN echo "ansible ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
.
4. Missing Python Dependencies
While you have python3 installed, some Ansible modules require specific Python libraries to format their output.
The Problem: For the ping module to work on an Ubuntu-based container, you often need the python3-apt or python3-distutils packages.
The Fix: Update your Dockerfile to include these common libraries in your apt-get install step
.
5. Inventory Syntax Verification
Double-check that there are no hidden characters or formatting errors in your inventory.ini. It should look exactly like this, with no spaces around the = signs:
target_container ansible_host=172.17.80.1 ansible_port=2222 ansible_user=ansible ansible_python_interpreter=/usr/bin/python3
Summary of Troubleshooting Steps
Run with -vvv to see the actual text being returned instead of JSON.
Check for login banners or echo commands in the user's shell profile.
Confirm the Python path inside the container by running podman exec [ID] which python3 to ensure it matches your inventory.
Try the raw module again with a command like ansible target_container -m raw -a "python3 --version". If this returns the version correctly but ping fails, the issue is almost certainly "noise" in the shell or a missing dependency.