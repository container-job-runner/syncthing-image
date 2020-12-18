#!/bin/bash

if [ -z "$USER_NAME" ] ; then
    USER_NAME=syncthing
fi

# -- create new user -----------------------------------------------------------
if [ -z "$USER_ID" ] || [ -z "$GROUP_ID" ] ; then
    useradd -ml $USER_NAME
else
    groupadd -o --gid $GROUP_ID $USER_NAME
    useradd -mlo --uid $USER_ID --gid $GROUP_ID $USER_NAME
fi

# -- copy syncthing config -----------------------------------------------------
mkdir -p /home/$USER_NAME/.config/syncthing/
cp /opt/syncthing/config/* /home/$USER_NAME/.config/syncthing/
chown -R $USER_NAME:$USER_NAME /home/$USER_NAME/.config
# -- copy syncthing start script -----------------------------------------------
cp /opt/syncthing/start.sh /home/$USER_NAME/start.sh
chmod u+x /home/$USER_NAME/start.sh
chown $USER_NAME:$USER_NAME /home/$USER_NAME/start.sh

# -- start command (or user override) ------------------------------------------
CMD="$@"
if [ -z "$CMD" ] ; then
    CMD="/home/$USER_NAME/start.sh"
fi
exec sudo -E -u $USER_NAME bash -l -c "$CMD"