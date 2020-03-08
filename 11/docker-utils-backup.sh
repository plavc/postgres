#!/usr/bin/env bash
set -Eeo pipefail
IFS=$'\n\t'

PGDATA="${PGDATA:-/var/lib/postgresql/data}"
BACKUP_DIR="${BACKUP_DIR:-/backup}"

# check to see if this file is being run or sourced from another script
_is_sourced() {
	# https://unix.stackexchange.com/a/215279
	[ "${#FUNCNAME[@]}" -ge 2 ] \
		&& [ "${FUNCNAME[0]}" = '_is_sourced' ] \
		&& [ "${FUNCNAME[1]}" = 'source' ]
}

# usage: docker_utils_postgres_backup
# Creates a postgres data folder backup and stores in /backup directory
docker_utils_postgres_backup() {
    local timestamp
    timestamp=$(date "+%Y-%m-%d-%H%M%S")
    tar -czvf "${BACKUP_DIR}/pgdata-backup-${timestamp}.tar.gz" "$PGDATA"
}

# usage: docker_utils_postgres_restore
# Creates a postgres data folder backup and stores in /backup directory
docker_utils_postgres_restore() {
    rm -rfv "$PGDATA"
    tar -xzvf "${BACKUP_DIR}/$1" -C "$PGDATA"
}

_main_utils_backup() {
	if [ "$1" = 'backup' ]; then
		docker_utils_postgres_backup
	elif [ "$1" = 'restore' ]; then
	    docker_utils_postgres_restore "$2"
	fi
}

if ! _is_sourced; then
	_main_utils_backup "$@"
fi
