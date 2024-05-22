
ARG BASE_IMAGE
FROM ${BASE_IMAGE}

RUN apt-get update && \
    apt-get install xorriso curl gpg fdisk sudo	squashfs-tools wget -y && \
    mkdir /build

WORKDIR /work
