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

# Get the database connection settings from environment or a linked container
DB_USER=${USER:-$DB_ENV_USER}
DB_PASS=${PASS:-$DB_ENV_PASS}
DB_NAME=${DB:-$DB_ENV_DB}
DB_ADDR=${ADDR:-$DB_PORT_5432_TCP_ADDR}
DB_PORT=${PORT:-$DB_PORT_5432_TCP_PORT}

echo "Used database settings:"
echo "DB_USER=$DB_USER"
echo "DB_PASS=$DB_PASS"
echo "DB_NAME=$DB_NAME"
echo "DB_ADDR=$DB_ADDR"
echo "DB_PORT=$DB_PORT"

# Replace in syncserver config
sed -i s/DB_USER/$DB_USER/ /home/ffsync/syncserver.ini
sed -i s/DB_PASS/$DB_PASS/ /home/ffsync/syncserver.ini
sed -i s/DB_NAME/$DB_NAME/ /home/ffsync/syncserver.ini
sed -i s/DB_ADDR/$DB_ADDR/ /home/ffsync/syncserver.ini
sed -i s/DB_PORT/$DB_PORT/ /home/ffsync/syncserver.ini

# Set the hostname
HOST=${HOST:-0.0.0.0}
echo "HOSTNAME=$HOST"
sed -i s/HOST_NAME/$HOST/ /home/ffsync/syncserver.ini

echo "Starting SyncServer..."
su ffsync -c '/home/ffsync/syncserver/local/bin/pserve /home/ffsync/syncserver.ini'
