# Developer Documentation

## 1. Project architecture

The project is composed of three containers:

```text
                 HTTPS :443
                     |
                  NGINX
                     |
             FastCGI / PHP-FPM
                     |
                WORDPRESS
                     |
                  MariaDB
```

The services are connected through the Docker Compose bridge network.

Persistent storage is separated into two volumes:

```text
wordpress_data  -> /home/mbouchri/data/docker/volumes/srcs_wordpress_data/_data
mariadb_data    -> /home/mbouchri/data/docker/volumes/srcs_mariadb_data/_data
```

## 2. Prerequisites

Install and verify:

```bash
docker --version
docker compose version
make --version
```

The project is intended to run inside the project VM.

The repository should contain:

```text
Makefile
srcs/
README.md
USER_DOC.md
DEV_DOC.md
```

## 3. Configuration files

### Environment file

General configuration is stored in:

```text
srcs/.env
```

Current values:

```env
MYSQL_DATABASE=wordpress
MYSQL_USER=wpuser
```

### Docker secrets

Sensitive values are stored under:

```text
secrets/
├── credentials.txt
├── db_password.txt
└── db_root_password.txt
```

The Compose file mounts them as Docker secrets instead of putting passwords directly into Dockerfiles.

These files must be created locally before starting the project because they are excluded from Git.

## 4. Service Dockerfiles

There is one Dockerfile per service:

```text
srcs/requirements/mariadb/Dockerfile
srcs/requirements/nginx/Dockerfile
srcs/requirements/wordpress/Dockerfile
```

### MariaDB

The MariaDB image installs MariaDB Server, initializes the database when needed, creates the WordPress database/user, and starts `mariadbd` in the foreground.

Configuration:

```text
srcs/requirements/mariadb/conf/50-server.cnf
```

Initialization script:

```text
srcs/requirements/mariadb/tools/init.sh
```

### NGINX

The NGINX image installs NGINX and OpenSSL, creates a self-signed certificate, and runs NGINX in the foreground.

Configuration:

```text
srcs/requirements/nginx/conf/nginx.conf
```

NGINX exposes HTTPS on port 443 only and allows TLS 1.2 and TLS 1.3.

### WordPress

The WordPress image installs PHP-FPM and the required PHP extensions, downloads WordPress, installs WP-CLI, and runs PHP-FPM in the foreground.

PHP-FPM configuration:

```text
srcs/requirements/wordpress/conf/www.conf
```

Initialization script:

```text
srcs/requirements/wordpress/tools/setup.sh
```

The startup script copies the WordPress files into the persistent WordPress volume when needed, waits for MariaDB to become reachable, generates `wp-config.php`, installs WordPress, and creates the additional user.

## 5. Docker Compose

The main Compose file is:

```text
srcs/docker-compose.yml
```

It defines:

- `nginx`
- `wordpress`
- `mariadb`
- the `inception` bridge network
- `wordpress_data`
- `mariadb_data`
- Docker secrets

Validate the Compose configuration without starting containers:

```bash
docker compose --env-file srcs/.env -f srcs/docker-compose.yml config
```

## 6. Makefile

From the repository root:

```bash
make
```

Build images:

```bash
make build
```

Start the stack:

```bash
make up
```

Stop the stack:

```bash
make down
```

Remove containers, locally built images, and orphan containers:

```bash
make clean
```

Perform the same cleanup as `make clean`:

```bash
make fclean
```

Rebuild everything:

```bash
make re
```

The persistent Docker volumes are preserved during normal cleanup.

## 7. Manual Docker Compose commands

Start:

```bash
docker compose --env-file srcs/.env -f srcs/docker-compose.yml up -d
```

Build and start:

```bash
docker compose --env-file srcs/.env -f srcs/docker-compose.yml up -d --build
```

Stop:

```bash
docker compose --env-file srcs/.env -f srcs/docker-compose.yml down
```

View status:

```bash
docker compose --env-file srcs/.env -f srcs/docker-compose.yml ps
```

View logs:

```bash
docker compose --env-file srcs/.env -f srcs/docker-compose.yml logs
```

Follow logs for one service:

```bash
docker compose --env-file srcs/.env -f srcs/docker-compose.yml logs -f wordpress
```

## 8. Containers

List running containers:

```bash
docker ps
```

Inspect a container:

```bash
docker inspect wordpress
```

Open a shell in a running container when required for debugging:

```bash
docker exec -it wordpress bash
```

Use the appropriate shell available in the image.

## 9. Volumes and persistence

List volumes:

```bash
docker volume ls
```

Inspect the project volumes:

```bash
docker volume inspect srcs_wordpress_data
docker volume inspect srcs_mariadb_data
```

The important host data locations are:

```text
/home/mbouchri/data/docker/volumes/srcs_wordpress_data/_data
/home/mbouchri/data/docker/volumes/srcs_mariadb_data/_data
```

Docker's data root is configured as `/home/mbouchri/data/docker`, allowing Docker to store the named volumes under `/home/mbouchri/data`.

Do not remove the volumes or host data directories when testing normal persistence.

After a VM reboot, start the stack again with:

```bash
make up
```

The WordPress website, WordPress configuration, and MariaDB database should remain available because the data is stored in persistent volumes.

## 10. Useful checks

Test the HTTPS endpoint:

```bash
curl -kI https://mbouchri.42.fr
```

Check that port 443 is published:

```bash
docker compose --env-file srcs/.env -f srcs/docker-compose.yml ps
```

Check the network:

```bash
docker network ls
docker network inspect srcs_inception
```

Check database logs:

```bash
docker logs mariadb
```

Check WordPress logs:

```bash
docker logs wordpress
```

Check NGINX logs:

```bash
docker logs nginx
```

Test TLS 1.2:

```bash
openssl s_client -connect mbouchri.42.fr:443 -tls1_2
```

Test TLS 1.3:

```bash
openssl s_client -connect mbouchri.42.fr:443 -tls1_3
```