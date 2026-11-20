FROM debian:12

RUN apt-get update \
    && apt-get install -y --no-install-recommends nginx openssl ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && rm -f /etc/nginx/sites-enabled/default

RUN mkdir -p /etc/nginx/ssl \
    && openssl req -x509 -nodes -days 365 \
       -newkey rsa:2048 \
       -keyout /etc/nginx/ssl/nginx.key \
       -out /etc/nginx/ssl/nginx.crt \
       -subj "/CN=mbouchri.42.fr" \
       -addext "subjectAltName=DNS:mbouchri.42.fr"

COPY conf/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]

