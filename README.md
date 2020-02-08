# plavchub/postgres

https://hub.docker.com/r/plavchub/postgres

A postgres image based on [official](https://hub.docker.com/_/postgres) image 
with additional support for patching and backup.

## Supported tags

- [`12`, `latest`](12/Dockerfile)
- [`12-alpine`](12/alpine/Dockerfile)
- [`11`](11/Dockerfile)
- [`11-alpine`](11/alpine/Dockerfile)
- [`10`](10/Dockerfile)
- [`10-alpine`](10/alpine/Dockerfile)
- [`9`](9/Dockerfile)
- [`9-alpine`](9/alpine/Dockerfile)

## How to use image

### Basic usage

`docker run --name postgres -e POSTGRES_PASSWORD=mysecretpassword -d plavchub/postgres`

### Additional features

### Patch scripts

Patching is supported by following similar approach as in official image with initial scripts.

Patches can be applied by adding `.sql`, `.sql.gz` or `.sh` scripts under `/docker-entrypoint-patches.d`.
Scripts are executed upon container start when a database was already initialized (first run of a container).

For each successfully applied patch a new file is created with the same name as the patch script
and suffix `.applied`.

For how to prepare patch scripts see [official](https://hub.docker.com/_/postgres) instructions for preparing initial scripts. 
The same rules are applied.

### Backup and restore

Docker image supports creating backups of the whole data folder `PG_DATA`. 
Backup can be created by running container with command `backup`. 
Backup files are stored in `/backup` folder. It is recommended to create backups
on a stopped containers or data loss my occur.

In the same manner database can be restored. Backup files for restoring database
must be in folder `/backup`.

***Example of executing backup***

`docker run --name postgres plavchub/postgres backup`

***Example of executing restore***

`docker run --name postgres plavchub/postgres restore backup-2020-02-08-100000.tar.gz`

