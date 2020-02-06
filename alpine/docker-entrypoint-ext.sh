#!/usr/bin/env bash
set -Eeo pipefail

source docker-entrypoint.sh
source docker-utils-backup.sh

# usage: docker_process_patch_files [file [file [...]]]
#    ie: docker_process_patch_files /always-patches.d/*
# process initializer files, based on file extensions and permissions
docker_process_patch_files() {
	# psql here for backwards compatiblilty "${psql[@]}"
	psql=( docker_process_sql )

	echo
	local f
	for f; do
	    if [ ! -f "$f.applied" ]; then
            case "$f" in
                *.sh)
                    # https://github.com/docker-library/postgres/issues/450#issuecomment-393167936
                    # https://github.com/docker-library/postgres/pull/452
                    if [ -x "$f" ]; then
                        echo "$0: running $f"
                        "$f"
                        docker_mark_applied "$f"
                    else
                        echo "$0: sourcing $f"
                        . "$f"
                        docker_mark_applied "$f"
                    fi
                    ;;
                *.sql)
                    echo "$0: running $f"
                    docker_process_sql -f "$f"
                    docker_mark_applied "$f"
                    echo
                    ;;
                *.sql.gz)
                    echo "$0: running $f"
                    gunzip -c "$f" | docker_process_sql
                    docker_mark_applied "$f"
                    echo
                    ;;
                *.applied)
                    ;;
                *)
                    echo "$0: ignoring $f"
                    ;;
            esac
        fi
		echo
	done
}

# usage: docker_mark_applied file
#    ie: docker_mark_applied 01_patch.sql
# Creates an empty file with name consisting of source filename appended with .applied
docker_mark_applied() {
    touch "$1.applied"
}

_main_ext() {

    if [ "$1" = 'backup' ]; then
        echo "PostgreSQL creating backup."
        docker_utils_postgres_backup
        exit 0
    fi

    if [ "$1" = 'restore' ]; then
        echo "PostgreSQL restoring backup. Existing data will be overwriten!"
        docker_utils_postgres_restore "$2"
        exit 0
    fi

    docker_setup_env

    docker_create_db_directories

    if [ "$(id -u)" = '0' ]; then
        # then restart script as postgres user
        exec su-exec postgres "$BASH_SOURCE" "$@"
    fi

    # only apply patches on an existing database
    if [ -n "$DATABASE_ALREADY_EXISTS" ]; then

        echo 'PostgreSQL applying patches.'

        docker_temp_server_start "$@"

        docker_process_patch_files /docker-entrypoint-patches.d/*

        docker_temp_server_stop

        echo
        echo 'PostgreSQL patches apply process complete; ready for start up.'
        echo
    fi

    _main "$@"
}

if ! _is_sourced; then
	_main_ext "$@"
fi
