ARG UBUNTU_VERSION=jammy
FROM ubuntu:${UBUNTU_VERSION}

RUN apt-get update \
  && apt-get install --yes --no-install-recommends \
      ca-certificates \
      curl \
      fdisk \
      gpg \
      squashfs-tools \
      sudo \
      wget \
      xorriso \
  && apt-get clean \
  && rm -rf \
    /var/lib/apt/lists/*

WORKDIR /work
