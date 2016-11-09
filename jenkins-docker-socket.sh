#!/bin/bash
set -x

DOCKER_SOCKET=/var/run/docker.sock

if [ -S ${DOCKER_SOCKET} ]; then
    DOCKER_GID=$(stat -c '%g' ${DOCKER_SOCKET})
    DOCKER_GROUP=$(stat -c '%G' ${DOCKER_SOCKET})
    JENKINS_USER=jenkins
    groupadd -for -g ${DOCKER_GID} ${DOCKER_GROUP}
    usermod -aG ${DOCKER_GROUP} ${JENKINS_USER}
fi

if [ "$1" = 'jenkins' ]; then
    # chown -R jenkins:jenkins "$JENKINS_HOME"
    exec gosu "$@"
fi
e
exec "$@"
