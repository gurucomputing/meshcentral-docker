#!/bin/sh
# this script will run on docker container load
# performs pre-checks and starts the main application

#----#
# placeholder for testing
# while true; do sleep 1; done
#----#

# set our home to a more generic home folder.
export HOME=/meshcentral/home

# Checks if the /meshcentral/meshcentraldata is owned by the user running meshcentral
# If not, the container will attempt to change the ownership permissions of the meshcentral folder 
if [ $(id -u) -ne $(stat -c %u /meshcentral/meshcentral-data) ]
then
    if [ $(id -u) -eq 1000 ]
    then
        echo "---- Detected File Permission Mismatch"
        echo "---- Forcing File Permissions to the node user ----"
        sudo /bin/chown -R 1000:1000 /meshcentral
    else
        echo "---- You are not running as the node user AND your file permissions don't match your user ---\n"
        echo "---- You may need to manually fix your file permissions ----"
    fi
fi

# generate a config.json if it doesn't exist
if [ ! -f /meshcentral/meshcentral-data/config.json ];
then
    echo "---- No config.json file detected. Creating based on Environment Variables ----"
    /bin/sh /staging/scripts/3-generate-config.sh
fi

# start meshcentral
echo "---- Starting Meshcentral ----"
node /meshcentral/node_modules/meshcentral/meshcentral.js
