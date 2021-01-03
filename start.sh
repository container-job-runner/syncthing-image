#!/bin/bash

# -- verify all variables are set ----------------------------------------------
if [ -z "$SYNCTHING_LISTEN_PORT" ] || [ -z "$SYNCTHING_CONNECT_PORT" ] || [ -z "$SSH_USERNAME" ] || [ -z "$SSH_IP" ] || [ -z "$SSH_KEY" ] ; then
  exit 1
fi

# -- start ssh tunnel (autossh) ------------------------------------------------
autossh -M 0 -f \
    -N -i $SSH_KEY \
    -o "StrictHostKeyChecking=no" \
    -o "ServerAliveInterval=30" \
    -o "ServerAliveCountMax=2" \
    -L 127.0.0.1:$SYNCTHING_CONNECT_PORT:127.0.0.1:$SYNCTHING_LISTEN_PORT \
    -R 127.0.0.1:$SYNCTHING_CONNECT_PORT:127.0.0.1:$SYNCTHING_LISTEN_PORT \
    $SSH_USERNAME@$SSH_IP

#----> equivalent ssh command
# ssh -fN -i $SSH_KEY \
#     -o "StrictHostKeyChecking=no" \
#     -o "ServerAliveInterval=30" \
#     -o "ServerAliveCountMax=2" \
#     -L 127.0.0.1:$SYNCTHING_CONNECT_PORT:127.0.0.1:$SYNCTHING_LISTEN_PORT \
#     -R 127.0.0.1:$SYNCTHING_CONNECT_PORT:127.0.0.1:$SYNCTHING_LISTEN_PORT \
#     $SSH_USERNAME@$SSH_IP

if [ $? -ne 0 ] ; then
    exit 2
fi

# -- configure ports -----------------------------------------------------------
sed -i "s/{{ SYNCTHING_LISTEN_PORT }}/$SYNCTHING_LISTEN_PORT/g" ~/.config/syncthing/config.xml
sed -i "s/{{ SYNCTHING_CONNECT_PORT }}/$SYNCTHING_CONNECT_PORT/g" ~/.config/syncthing/config.xml
sed -i "s/{{ SYNCTHING_GUI_PORT }}/$SYNCTHING_GUI_PORT/g" ~/.config/syncthing/config.xml
sed -i "s/{{ SYNCTHING_SYNC_DIRECTORY }}/$(echo $SYNCTHING_SYNC_DIRECTORY | sed -e 's/[\/&]/\\&/g')/g" ~/.config/syncthing/config.xml

# -- start syncthing -----------------------------------------------------------
syncthing -no-browser

if [ $? -ne 0 ] ; then
    exit 3
fi