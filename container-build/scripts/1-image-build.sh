#!/bin/sh
# Image Build Script for Meshcentral

# Generic pre-requisites for all maintained alpine images
# sudo             used to elevate a startup script for fixing file permissions
# libcap           used to allow binaries to bind to lower ports as non root 
apk add --no-cache sudo libcap

# pre-requisites for meshcentral
# mongodb-tools    used if a mongodb installation is used
# jo               used to craft the initial settings.json file
# jq               json parser, can be used to filter json files
apk add --no-cache mongodb-tools jo jq

# Add the ability to set file permissions to the non-privileged user
echo "ALL ALL=NOPASSWD: chown -R 1000:1000 /meshcentral" >> /etc/sudoers

# Set the workdir for meshcentral
mkdir -p /meshcentral/home
cd /meshcentral

# Install meshcentral
echo ${VERSION}
npm install meshcentral@${VERSION}

# Allow node to bind to lower ports, even if not running as root
setcap CAP_NET_BIND_SERVICE=+eip /usr/local/bin/node