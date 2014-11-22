#!/usr/bin/env bash

# Restore backuped date into mailman.
# Takes the backup file name (A tar file) as argument.

# Abort if file doesn't exist:
set -e

BACK_DIR="backup_temp"

# Extract the Tar file into backup_temp:
tar -xvf $1 -C ./

set +e

# Backup the data, lists and archives mailman directories
# by copying them to backup_temp directory on the host:
docker run --name mailman_data_restore_cont \
	--volumes-from mailman_data_cont \
	-v $(readlink -f $BACK_DIR):/backup \
        mailman_data \
	sh -c "\
	rm -rfv /var/lib/mailman/data/* && \
	rm -rfv /var/lib/mailman/lists/* && \
	rm -rfv /var/lib/mailman/archives/* && \
        cp -R /backup/data /var/lib/mailman && \
        cp -R /backup/lists /var/lib/mailman && \
        cp -R /backup/archives /var/lib/mailman "

# Clean up: remove mailman_data_restore container:
docker rm -f mailman_data_restore_cont

# Remove the backups folder (We got it from opening the tar):
rm -R $BACK_DIR
