FROM nginx
MAINTAINER jdellinger, jay@dellingertechnologies.com

ENV DOCKER_HOST unix:///tmp/docker.sock
ENV FOREGO_DOWNLOAD_URL https://godist.herokuapp.com/projects/ddollar/forego/releases/current/linux-amd64/forego
ENV DOCKER_GEN_VERSION 0.4.2
ENV DOCKER_GEN_DOWNLOAD_URL https://github.com/jwilder/docker-gen/releases/download/$DOCKER_GEN_VERSION/docker-gen-linux-amd64-$DOCKER_GEN_VERSION.tar.gz

# Foreman in Go language
# Docker-gen is a library to generate the nginx configuration file
# nginx.conf: Fix for long server names
RUN apt-get update && \
  apt-get install -y wget && \
  wget -P /usr/local/bin $FOREGO_DOWNLOAD_URL && \
  chmod u+x /usr/local/bin/forego && \
  wget $DOCKER_GEN_DOWNLOAD_URL && \
  tar -C /usr/local/bin -xvzf docker-gen-linux-amd64-$DOCKER_GEN_VERSION.tar.gz && \
  rm docker-gen-linux-amd64-$DOCKER_GEN_VERSION.tar.gz && \
  sed -i 's/# server_names_hash_bucket/server_names_hash_bucket/g' /etc/nginx/nginx.conf && \
  mkdir /etc/nginx/ssl/ /etc/nginx/htpasswd/

# Allow to access the generated nginx configuration file
VOLUME ["/etc/nginx/sites-enabled/"]
# SSL certificates directory
VOLUME ["/etc/nginx/ssl/"]
# Basic auth htpasswd files directory
VOLUME ["/etc/nginx/htpasswd/"]

RUN mkdir /app
WORKDIR /app
ADD . /app

EXPOSE 80 443
CMD ["forego", "start", "-r"]
