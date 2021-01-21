#!/bin/bash

# -- verify all variables are set ----------------------------------------------
if [ -z "$SYNCTHING_LISTEN_PORT" ] || [ -z "$SYNCTHING_CONNECT_PORT" ] ; then
  exit 1
fi

# -- configure ports -----------------------------------------------------------
sed -i "s/{{ SYNCTHING_LISTEN_PORT }}/$SYNCTHING_LISTEN_PORT/g" ~/.config/syncthing/config.xml
sed -i "s/{{ SYNCTHING_CONNECT_PORT }}/$SYNCTHING_CONNECT_PORT/g" ~/.config/syncthing/config.xml
sed -i "s/{{ SYNCTHING_GUI_PORT }}/$SYNCTHING_GUI_PORT/g" ~/.config/syncthing/config.xml
sed -i "s/{{ SYNCTHING_FS_WATCHER_DELAY_S }}/$SYNCTHING_FS_WATCHER_DELAY_S/g"  ~/.config/syncthing/config.xml
sed -i "s/{{ SYNCTHING_RESCAN_INTERVAL_S }}/$SYNCTHING_RESCAN_INTERVAL_S/g"  ~/.config/syncthing/config.xml
sed -i "s/{{ SYNCTHING_SYNC_DIRECTORY }}/$(echo $SYNCTHING_SYNC_DIRECTORY | sed -e 's/[\/&]/\\&/g')/g" ~/.config/syncthing/config.xml

# -- manually create .stfolder -------------------------------------------------
mkdir -p "$SYNCTHING_SYNC_DIRECTORY/.stfolder"

# -- start syncthing -----------------------------------------------------------
syncthing -no-browser

if [ $? -ne 0 ] ; then
    exit 2
fi