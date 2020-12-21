#!/bin/bash

# -- verify all variables are set ----------------------------------------------
if [ -z "$SYNCTHING_LISTEN_PORT" ] || [ -z "$SYNCTHING_CONNECT_PORT" ] ; then
  exit 1
fi

# -- configure ports -----------------------------------------------------------
sed -i "s/{{ SYNCTHING_LISTEN_PORT }}/$SYNCTHING_LISTEN_PORT/g" ~/.config/syncthing/config.xml
sed -i "s/{{ SYNCTHING_CONNECT_PORT }}/$SYNCTHING_CONNECT_PORT/g" ~/.config/syncthing/config.xml
sed -i "s/{{ SYNCTHING_GUI_PORT }}/$SYNCTHING_GUI_PORT/g" ~/.config/syncthing/config.xml

# -- start syncthing -----------------------------------------------------------
syncthing -no-browser

if [ $? -neq 0 ] ; then
    exit 2
fi