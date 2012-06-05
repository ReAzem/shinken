#!/bin/bash

# Check if the reqs changed
# If the reqs match the previous, copy the previous environment
# Otherwise, create a new one, calc the hash and before going anywhere, copy it under here.
HASH=$(cat test/jenkins/requirements.tests.freeze requirements.freeze|md5sum|cut -d' ' -f1)
if [ -e ../last_env_hash ]; then
  OLDHASH=$(cat ../last_env_hash)
else
  OLDHASH=""
fi
echo $HASH > ../last_env_hash

echo OLD REQS HASH AND NEW REQS HASH: $OLDHASH $HASH


# Cache the environment if it hasn't changed.
if [ "$OLDHASH" != "$HASH" ]; then
  echo "ENVIRONMENT SPECS CHANGED - CREATING A NEW ENVIRONMENT"
  virtualenv --distribute env
  . env/bin/activate
  pip install --upgrade pip
  pip install -r requirements.freeze
  pip install -r test/jenkins/requirements.tests.freeze
  rm -rf ../last_env
  cp -ar env ../last_env
else
  echo "ENVIRONMENT SPECS HAVE NOT CHANGED - USING CACHED ENVIRONMENT"
  cp -ar ../last_env env
  . env/bin/activate
fi;

pip install -e .
