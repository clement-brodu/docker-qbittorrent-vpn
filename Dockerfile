# syntax=docker/dockerfile:1

FROM lscr.io/linuxserver/qbittorrent:latest

LABEL maintainer='clement-brodu'

# install runtime packages and qbitorrent-cli
RUN \
  echo "**** install packages ****" && \
  apk add --no-cache --upgrade grep && \
  apk add --no-cache \
    iputils-ping \
    jq \
    traceroute \
    openvpn \
    moreutils \
    net-tools \
    dos2unix \
    kmod \
    iptables \
    ipcalc \
    binutils

# add local files
COPY root/ /

