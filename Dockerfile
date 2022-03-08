# Docker file for Cockpit Sync Utility
# Allows running sync in a self-sufficient container without prerequisites on the host system.
#
# As Cockpit Sync reads and writes to a Cockpit Docker volume, this container requires a mounted Docker socket.
# The Docker socket can be mounted from the host system with `-v /run/run/docker.sock:/run/run/docker.sock`.
#
# The image can be built and tagged via `docker build -t custom/cockpit-sync .`.
#
# Archive origin/destination can be mounted via `-v /var/app/archive:/var/app/archive` (path must be absolute).
# 
# Sync requires a volume name and an archive directory mounted for save and restore operations.
# The archive path supplied as an argument to `cockpit-sync` must be mounted as-is (with the exact same path) to the container.
# It should be noted that the mount point perspective for this container is equal to the host and does not change when nesting.
#
# An example use of this image with a volume named "project-data-cockpit" and an archive at "/var/app/archive":
# `docker run -it --rm -v /run/run/docker.sock:/run/run/docker.sock -v /var/app/archive:/var/app/archive custom/cockpit-sync <mode> -v project-data-cockpit -a /var/app/archive`
#

FROM swift:5.5-slim

ARG DOCKER_KEY_URL=https://download.docker.com/linux/ubuntu/gpg
ARG DOCKER_DEP_URL=https://download.docker.com/linux/ubuntu

RUN apt update
RUN apt install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
RUN curl -fsSL ${DOCKER_KEY_URL} | apt-key add -
RUN add-apt-repository "deb [arch=amd64] ${DOCKER_DEP_URL} $(lsb_release -cs) stable"
RUN apt update
RUN apt install -y docker-ce-cli containerd.io

ARG COCKPIT_SYNC_URL=http://drop.augustfreytag.com/cockpit-sync-1.2.1-linux-x86-64.tar.gz
ADD ${COCKPIT_SYNC_URL} /tmp/cockpit-sync.tar.gz
RUN tar -xzf /tmp/cockpit-sync.tar.gz -C /tmp
RUN rm /tmp/cockpit-sync.tar.gz
RUN mv /tmp/CockpitSync /usr/local/bin/cockpit-sync

ENTRYPOINT ["/usr/local/bin/cockpit-sync"]