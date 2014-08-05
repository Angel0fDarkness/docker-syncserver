#!/bin/bash
# Start the Mozilla Firefox Syncserver

set -e #Stop on error

# Check whether a custom secret has been set in config, otherwise generate one
if grep -Fq "INSERT_SECRET_KEY_HERE" /home/ffsync/syncserver.ini
then
	RANDOM_KEY=0
	echo "No secret key found, generating random one..."
	RANDOM_KEY=`head -c 20 /dev/urandom | sha1sum`
	sed -i s/INSERT_SECRET_KEY_HERE/${RANDOM_KEY:0:40}/ /home/ffsync/syncserver.ini
fi

echo "Starting SyncServer..."
su ffsync -c '/home/ffsync/syncserver/local/bin/pserve /home/ffsync/syncserver.ini'
