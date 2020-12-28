# cjrun/syncthing:local
This branch builds the image **cjrun/syncthing:local** that [cjr](https://container-job-runner.github.io/) uses to run Syncthing on a local computer. The image is part of the official cjr repository [syncthing](https://hub.docker.com/u/cjrun).
If provided the necessary information, a container that is run from this image will start a tunneled ssh connection with the remote host (which should be running the a container from the image **cjrun/syncthing:remote**).

**IMPORTANT**: These containers are meant to be used by cjr using ssh tunneling. **Do not** use these containers as a starting point for running a publicly exposed syncthing server, **unless you change the private keys** and the config files.

## Usage

If the entrypoint and command are left unchange, then any container that runs from the image **cjrun/syncthing:local** will respond to the following environment variables:
- *USER_ID*: user id of container user; to sync bound directories, this must match the id of current user.
- *GROUP_ID*: group id of container user; to sync bound directories, this must match the group id of current user.
- *SSH_KEY* : Location in container where ssh key for accessing remote resource is stored (the key to you sever will not be contained in the image. You must manually bind it to the container).
- *SSH_IP* : IP Address of remote resource.
- *SSH_USERNAME* : username to access remote resource.
- *SYNCTHING_SYNC_DIRECTORY* (optional) : the directory in the container that syncthing should keep syncronized. The default is /home/syncthing/sync-directory
- *SYNCTHING_GUI_PORT* (optional) : port that syncthing uses for the web GUI. The default is 8384.
- *SYNCTHING_LISTEN_PORT* (optional) : port that Syncthing uses to listen to remote connections. The default is 22000. 
- *SYNCTHING_CONNECT_PORT* (optional) : port that local Syncthing uses to connect to remote Syncthing. The default is 22001. 

**IMPORTANT:** If *SYNCTHING_LISTEN_PORT* or *SYNCTHING_CONNECT_PORT* are specified, then their values should be equivalent to the values used for the local container.

### Example start command

The container will synchronize the directory `SYNCTHING_SYNC_DIRECTORY`. You must bind the local directory that you wish to sync to this path (or inside this directory).
```shell
$ docker run -ti \
    -v /path/to/sync/directory:/home/syncthing/sync-directory \
    -v /path/to/key:/opt/syncthing/ssh_key:ro \
    --env SSH_KEY=/opt/syncthing/ssh_key --env SSH_IP=YOUR-REMOTE-IP --env SSH_USERNAME=YOUR-REMOTE-USERNAME \
    --env SYNCTHING_LISTEN_PORT=22000 --env SYNCTHING_CONNECT_PORT=22001 \
    cjrun/syncthing:local
```

## Description of build directories and files

- config : Syncthing configuration files for the image
- entrypoint.sh : creates a new linux user with specified UID and GID, configures Syncthing for this user, and runs the start command
- start.sh : default starting script for the image