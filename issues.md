#issues

List of issues during this project execution

## Workspace init issue

### Issue
Dev container cound not be loaded with following error :
ctivating feature 'alpine-bash'
./install.sh: 7: apk: not found
ERROR: Feature "alpine-bash" (ghcr.io/cirolosapio/devcontainers-features/alpine-
                                                                               -bash) failed to install! Look at the documentation at https://github.com/cirolos
                                                                               sapio/devcontainers-features/tree/main/src/alpine-bash for help tr


###  Resolution 
Updated install bash script to use correct docker build(removed ansible )


### Issue 2 
After fixing the scripts as above, Now I am getting following error.: [1/3] STEP 8/11: COPY post-create.sh /usr/local/bin/post-create.sh

--> 3a53ba230efd                                                                running runtime: exit status 127tmp/dev-container-

### Cause
It looks like you’ve hit another "exit status 127" error, which in the world of Linux/Containers, almost always means a command was called that simply doesn't exist in the environment.

### Resolution
Action: Update your devcontainer.json to only include the bare essentials.

To get your Ansible environment running immediately, we need to remove the non-essential "Features" that are conflicting with your base OS. The dot-config feature is failing because it's trying to execute scripts against a shell environment it doesn't recognize