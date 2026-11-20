*This project has been created as part of the 42 curriculum by mbouchri*.

# Description

## Project overview

Inception is a Docker infrastructure project that deploys a small web stack using Docker Compose.

The stack contains three services:

- **NGINX**: the only entry point from the host. It handles HTTPS and forwards PHP requests to WordPress.
- **WordPress + PHP-FPM**: provides the website and its administration panel.
- **MariaDB**: stores the WordPress database.

The services communicate through a dedicated Docker bridge network. WordPress files and MariaDB data are stored in persistent Docker named volumes. Docker's data root is configured as `/home/mbouchri/data/docker`.

## Main design choices

- One Dockerfile is written for each service.
- Debian is used as the base distribution.
- Images are built locally with Docker Compose.
- NGINX exposes only port **443**.
- TLS 1.2 and TLS 1.3 are enabled.
- WordPress runs with PHP-FPM and does not contain NGINX.
- MariaDB is a separate database service.
- Docker secrets are used for passwords and credentials.
- A dedicated Docker bridge network is used for communication between containers.
- Docker named volumes provide persistent storage.
- The project is started and managed through the root Makefile and Docker Compose.

## Project structure

```text
inception/
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
├── secrets/
│   ├── credentials.txt
│   ├── db_password.txt
│   └── db_root_password.txt
└── srcs/
    ├── .env
    ├── docker-compose.yml
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile
        │   ├── conf/
        │   │   └── 50-server.cnf
        │   └── tools/
        │       └── init.sh
        ├── nginx/
        │   ├── Dockerfile
        │   └── conf/
        │       └── nginx.conf
        └── wordpress/
            ├── Dockerfile
            ├── conf/
            │   └── www.conf
            └── tools/
                └── setup.sh
```

## Virtual Machines vs Docker

A **virtual machine** emulates a complete computer, including its own operating system kernel. This gives strong isolation but uses more memory, storage, and startup time.

**Docker** uses containers that share the host kernel while isolating applications and their dependencies. Containers are usually lighter and faster to build, start, and manage.

For Inception, Docker is appropriate because each service can run in its own isolated container while communicating through a controlled Docker network.

## Secrets vs Environment Variables

**Environment variables** are convenient for non-sensitive configuration such as:

```env
MYSQL_DATABASE=wordpress
MYSQL_USER=wpuser
```

However, passwords and other sensitive credentials should not be stored directly in the environment or committed to the repository.

**Docker secrets** provide a dedicated way to mount sensitive values into containers, for example:

```text
/run/secrets/db_password
/run/secrets/db_root_password
/run/secrets/credentials
```

This project uses environment variables for general configuration and Docker secrets for passwords and account credentials.

## Docker Network vs Host Network

A **Docker bridge network** gives containers a private network where they can communicate using service names such as `mariadb` and `wordpress`.

With **host networking**, a container shares the host network namespace directly. This provides less network isolation and is not used in this project.

The project therefore uses a dedicated Docker bridge network named through Docker Compose.

## Docker Volumes vs Bind Mounts

A **bind mount** directly maps a specific host path into a container.

A **Docker named volume** is managed by Docker and can be configured with a driver and a host-backed location.

This project uses named volumes:

- `wordpress_data`
- `mariadb_data`

Their storage locations are:

```text
/home/mbouchri/data/docker/volumes/srcs_wordpress_data/_data
/home/mbouchri/data/docker/volumes/srcs_mariadb_data/_data
```

These are Docker-managed named volumes, not bind mounts. Docker's data root is configured to store persistent data under `/home/mbouchri/data/docker`.

# Instructions

## Prerequisites

- A Linux environment or the project virtual machine.
- Docker installed and running.
- Docker Compose available through `docker compose`.
- The repository cloned into an empty directory.
- The required secret files present in `secrets/`.

## Configuration

The general configuration is stored in:

```text
srcs/.env
```

Current non-sensitive values are:

```env
MYSQL_DATABASE=wordpress
MYSQL_USER=wpuser
```

Sensitive values are stored in:

```text
secrets/db_password.txt
secrets/db_root_password.txt
secrets/credentials.txt
```

Do not commit passwords or other credentials to Git.

## Build and start

From the repository root:

```bash
make
```

The Makefile builds the images and starts the stack.

To build only:

```bash
make build
```

To start the containers:

```bash
make up
```

## Stop the project

```bash
make down
```

## Access

Website:

```text
https://mbouchri.42.fr
```

WordPress administration panel:

```text
https://mbouchri.42.fr/wp-admin/
```

The hostname must resolve to the VM. For a local setup, `/etc/hosts` can contain:

```text
127.0.0.1 mbouchri.42.fr
```

NGINX listens on port 443 only.

# Resources

## Official documentation

- Docker documentation: https://docs.docker.com/
- Docker Compose documentation: https://docs.docker.com/compose/
- Docker volumes: https://docs.docker.com/engine/storage/volumes/
- Docker networking: https://docs.docker.com/engine/network/
- Docker secrets: https://docs.docker.com/engine/swarm/secrets/
- NGINX documentation: https://nginx.org/en/docs/
- PHP-FPM documentation: https://www.php.net/manual/en/install.fpm.php
- MariaDB documentation: https://mariadb.com/docs/
- WordPress documentation: https://wordpress.org/documentation/
- WP-CLI documentation: https://make.wordpress.org/cli/handbook/

## AI usage

AI was used as a learning and development aid during the project.

It was used for:

- Understanding Docker, Docker Compose, images, containers, networks, volumes, and secrets.
- Understanding the Inception subject requirements and correction criteria.
- Troubleshooting Docker Compose, container startup, NGINX, PHP-FPM, MariaDB, and WordPress configuration.
- Reviewing shell scripts, Dockerfiles, and Compose configuration for possible errors.
- Explaining commands and helping diagnose runtime errors.