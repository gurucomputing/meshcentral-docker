#!/bin/sh
# generate the config.json
settings=$(jo mongoDb=$MONGODB_URL mongoDbName=$MONGODB_NAME dbEncryptKey=$DB_ENCRYPT_KEY agentPort=$AGENT_PORT cert=$CERT)
config=$(jo settings=$settings)

# remove any null valued environment variables and generate config
jq -n "$config | del(..|nulls)" > /meshcentral/meshcentral-data/config.json