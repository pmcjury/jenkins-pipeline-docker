FROM jenkins:latest

USER root

ARG DOCKER_VERSION=1.12.2
ARG DOCKER_COMPOSE_VERSION=1.9.0-rc1
ARG GOSU_VERSION=1.10

RUN set -x \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install -y \
        net-tools \
        wget \
        ca-certificates \
    && dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')" \
    && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch" \
    && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
    && rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    && gosu nobody true \
    ### Install Docker client only
    && curl -fsSLO --create-dirs --output /usr/local/bin/docker \
        "https://get.docker.com/builds/$(uname -s)/$(uname -m)/docker-${DOCKER_VERSION}.tgz" \
    && tar --strip-components=1 -xvzf docker-${DOCKER_VERSION}.tgz -C /usr/local/bin \
    && chmod +x /usr/local/bin/docker \
    && curl -L https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose \
    && curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip" \
    && unzip awscli-bundle.zip \
    && ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws

# clean up
# RUN apt-get purge -y --auto-remove ca-certificates \
#   rm -rf /var/lib/apt/lists/* \
#    && rm -rf docker-${DOCKER_VERSION}.tgz awscli-bundle.zip awscli-bundle

# Make the jenkins user a sudoer
# Replace the docker binary with a sudo script
# RUN echo "jenkins ALL=NOPASSWD: ALL" >> /etc/sudoers \
#     && mv /usr/local/bin/docker /usr/local/bin/docker.bin \
#     && printf '#!/bin/bash\nsudo docker.bin "$@"\n' > /usr/local/bin/docker \
#     && chmod +x /usr/local/bin/docker \
#     && mv /usr/local/bin/docker-compose /usr/local/bin/docker-compose.bin \
#     && printf '#!/bin/bash\nsudo docker-compose.bin "$@"\n' > /usr/local/bin/docker-compose \
#     && chmod +x /usr/local/bin/docker-compose

USER jenkins

COPY jenkins-docker-socket.sh /usr/local/bin/jenkins-docker-socket.sh

COPY plugins.txt /usr/share/jenkins/ref/

RUN /usr/local/bin/plugins.sh /usr/share/jenkins/ref/plugins.txt

ENV JAVA_OPTS="-Xmx8192m"

USER root

ENTRYPOINT ["/usr/local/bin/jenkins-docker-socket.sh"]

CMD ["jenkins", "/bin/tini", "--", "/usr/local/bin/jenkins.sh"]
