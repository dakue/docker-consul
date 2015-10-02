#!/bin/bash
set -e

if [ "$1" = 'consul' ]
then
    echo "INFO: Executing envplate to replace environment variables in configuration file"
    /usr/local/bin/ep -v "${CONSUL_HOME}/config/consul.json"

    echo "INFO: Starting Consul ..."
    exec /usr/local/bin/consul agent --config-dir $CONSUL_HOME/config
fi

exec "$@"
