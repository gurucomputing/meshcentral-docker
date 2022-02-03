#!/bin/sh
# this script will run on docker container load
# performs pre-checks and starts the main application

#----#
# placeholder for testing
# while true; do sleep 1; done
#----#

# set our home to a more generic home folder.
export HOME=/meshcentral/home

# set file permissions. Calls the elevation script to modify permissions
echo "---- Setting File Permissions based on user ----"
sudo /bin/sh /staging/scripts/3-initialise-elevated.sh $(id -u) $(id -g)

# generate a config.json if it doesn't exist
if [ ! -f /meshcentral/meshcentral-data/config.json ];
then
    echo "---- No config.json file detected. Creating based on Environment Variables ----"
    /bin/sh /staging/scripts/4-generate-config.sh
fi

# start meshcentral
echo "---- Starting Meshcentral ----"
node /meshcentral/node_modules/meshcentral/meshcentral.js
