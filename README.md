# syncthing-image
A pair of Fedora based images for running Syncthing that are part of the official [cjr repository](https://hub.docker.com/u/cjrun) *syncthing*.

## Description

This repository can be used to build container images that enable two-way file sync using [Syncthing](https://syncthing.net) over tunneled ssh. The ssh tunnel is managed using [autossh](https://linux.die.net/man/1/autossh). See the following references for general information about using Syncthing over tunneled ssh and autossh.
- [Syncthing Tunneling](https://docs.syncthing.net/users/tunneling.html)
- [Syncthing Configuration](https://docs.syncthing.net/users/config.html)
- [SSH Tunneling for Fun and Profit](https://www.everythingcli.org/ssh-tunnelling-for-fun-and-profit-autossh/)

## Building
The image must be built using either `--build-arg MODE=local` or `--build-arg MODE=remote`


The *local image* should be pulled onto the source computer. A container that is run using the local image will initiate the ssh tunnel with the remote computer.
The *remote image* should be pulled on the remote computer. A container that is run using the remote image will not start any connections with the local computer.
Both the local and remote resource must have Docker or Podman installed.

**NOTE:** These containers are meant to be used by [cjr](https://github.com/container-job-runner/cjr) using ssh tunneling. Do not use these containers as a starting point for running a publicly exposed syncthing server, **unless you change the private keys** and reconfigure the config files.

## Usage (Remote Container)

A container that runs using the remote image responds to the following environment variables:
- *USER_ID*: user id of container user; to sync bound directories, this must match the id of current user.
- *GROUP_ID*: group id of container user; to sync bound directories, this must match the group id of current user.
- *SYNCTHING_LISTEN_PORT* (optional) : port that Syncthing uses to listen to remote connections (if specified, this should be equivalent to the value used for remote).
- *SYNCTHING_CONNECT_PORT* (optional) : port that local Syncthing uses to connect to remote Syncthing.

The remote container **must** be run using the `flag --network=host`. The container will synchronize the directory `home/syncthing/sync-directory`. You must bind the local directory that you wish to sync to this path.

### Example start command
```shell
$ docker run -ti --network=host \
    -v /path/to/sync/directory:/home/syncthing/sync-directory \
    --env USER_ID=$(id -u) --env GROUP_ID=$(id -g) \
    --env SYNCTHING_LISTEN_PORT=22000 --env SYNCTHING_CONNECT_PORT=22001 \
    cjrun/syncthing:remote
```

## Usage (Local Container)

A container that uses the local image responds to the following environment variables:
- *USER_ID*: user id of container user; to sync bound directories, this must match the id of current user.
- *GROUP_ID*: group id of container user; to sync bound directories, this must match the group id of current user.
- *SSH_KEY* : Location in container where ssh key for accessing remote resource is stored (the key to you sever will not be contained in the image. You must manually bind it to the container).
- *SSH_IP* : IP Address of remote resource.
- *SSH_USERNAME* : username to access remote resource.
- *SYNCTHING_LISTEN_PORT* (optional) : port that Syncthing uses to listen to remote connections (if specified, this must be equivalent to the value used for remote).
- *SYNCTHING_CONNECT_PORT* (optional) : port that local Syncthing uses to connect to remote Syncthing (if specified, this must be equivalent to the value used for remote).

The container will synchronize the directory `home/syncthing/sync-directory`. You must bind the local directory that you wish to sync to this path.

### Example start command

```shell
$ docker run -ti \
    -v /path/to/sync/directory:/home/syncthing/sync-directory \
    -v /path/to/key:/opt/syncthing/ssh_key:ro \
    --env SSH_KEY=/opt/syncthing/ssh_key --env SSH_IP=YOUR-REMOTE-IP --env SSH_USERNAME=YOUR-REMOTE-USERNAME \
    --env SYNCTHING_LISTEN_PORT=22000 --env SYNCTHING_CONNECT_PORT=22001 \
    cjrun/syncthing:local
```

If everything is successful, the two way file sync will be enabled once both commands are run on the local and remote computers.

## Description of Build Directories and Files

- local-config : Syncthing configuration files for local image
- remote-config : Syncthing configuration files for remote image
- entrypoint.sh : creates a new linux user with specified UID and GID, configures Syncthing for this user, and runs the start command
- local-start.sh : starting command for local image
- remote-start.sh : starting command for remote image