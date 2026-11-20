# User Documentation

## 1. What this project provides

The project provides a small web stack with three services:

- **NGINX**: secure HTTPS entry point.
- **WordPress**: website and administration interface, running with PHP-FPM.
- **MariaDB**: database used by WordPress.

The services are connected through a Docker network and the important data is stored persistently.

## 2. Starting the project

From the project root:

```bash
make
```

This builds the Docker images and starts the containers in the background.

To verify that they are running:

```bash
docker compose --env-file srcs/.env -f srcs/docker-compose.yml ps
```

All three services should be running:

```text
nginx
wordpress
mariadb
```

## 3. Stopping the project

To stop the stack:

```bash
make down
```

The persistent data is kept in the Docker volumes, so stopping the containers does not remove the website or database data.

## 4. Accessing the website

Open:

```text
https://mbouchri.42.fr
```

NGINX is the only service exposed to the host and it uses HTTPS on port 443.

For a local VM setup, make sure the hostname resolves correctly.

If accessing the website from the VM itself, `/etc/hosts` can contain:

```text
127.0.0.1 mbouchri.42.fr
```

If accessing the website from another machine, use the VM's reachable IP address instead.

A self-signed certificate may produce a browser warning. This is expected for the local project setup.

## 5. Accessing the administration panel

Open:

```text
https://mbouchri.42.fr/wp-admin/
```

Sign in with the WordPress administrator account created during the initial setup.

The administrator username used by this project is:

```text
mbouchri
```

## 6. Credentials

Sensitive credentials are stored in the `secrets/` directory:

```text
secrets/
├── credentials.txt
├── db_password.txt
└── db_root_password.txt
```

Do not publish these files to a public Git repository.

General configuration values are stored separately in:

```text
srcs/.env
```

The `.env` file contains non-sensitive values such as the database name and database user.

## 7. Checking the services

Check container status:

```bash
docker compose --env-file srcs/.env -f srcs/docker-compose.yml ps
```

Check all containers:

```bash
docker ps
```

Check logs:

```bash
docker logs nginx
docker logs wordpress
docker logs mariadb
```

Test HTTPS:

```bash
curl -kI https://mbouchri.42.fr
```

A successful setup should return an HTTP success response such as:

```text
HTTP/1.1 200 OK
```

Check the Docker network:

```bash
docker network ls
```

Check the volumes:

```bash
docker volume ls
```

## 8. Persistent data

The WordPress website data is stored through:

```text
wordpress_data
```

and the MariaDB database data through:

```text
mariadb_data
```

The actual Docker volume names are:

```text
srcs_wordpress_data
srcs_mariadb_data
```

Their storage locations are:

```text
/home/mbouchri/data/docker/volumes/srcs_wordpress_data/_data
/home/mbouchri/data/docker/volumes/srcs_mariadb_data/_data
```

These are Docker-managed named volumes.

Do not delete these directories or their corresponding volumes unless a complete reset is intended.