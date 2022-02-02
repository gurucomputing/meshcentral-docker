#!/bin/sh
# This script can be called as root from other scripts
# Be careful modifying -- anything ran (or caused to run)
# in here will be elevated

# Arguments
### UID and GID will be mandatory arguments given on run
userID=$1
groupID=$2

# file permissions
### set the ownership of the files
chown -R $userID:$groupID /meshcentral