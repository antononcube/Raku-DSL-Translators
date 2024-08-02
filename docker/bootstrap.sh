#!/bin/bash

if [ -z "$HOST" ]; then
     echo "Environment variable 'HOST' is not set!"
     exit 1
fi

if [ -z "$PORT" ]; then
     echo " Environment variable 'PORT' is not set!"
     exit 1
fi

echo "Executing Raku command"

# See if Raku if running
raku -e "say 1+1_000"

echo "Finished Raku command"

echo "Starting Raku-LLM Web Service at host $HOST and port $PORT."
raku bin/dsl-web-translation-service --host="$HOST" --port="$PORT"
