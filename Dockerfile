FROM fedora:33
RUN dnf install -y syncthing openssh-clients autossh ; dnf clean all ; mkdir -p /opt

# -- copy SyncThing configuration and start script -----------------------------
COPY "config" /opt/syncthing/config
COPY "start.sh" /opt/syncthing/start.sh

# -- copy entrypoint script ----------------------------------------------------
COPY entrypoint.sh /opt/
RUN chmod u+x /opt/entrypoint.sh

# -- set default environment variables -----------------------------------------
ENV USER_NAME=syncthing
ENV SYNCTHING_LISTEN_PORT=22000
ENV SYNCTHING_CONNECT_PORT=22001
ENV SYNCTHING_GUI_PORT=8384
ENV SYNCTHING_SYNC_DIRECTORY=/home/syncthing/sync-directory

ENTRYPOINT [ "/opt/entrypoint.sh" ]