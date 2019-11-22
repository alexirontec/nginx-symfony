FROM debian:stretch-slim

ARG NGINX_V=1.15.7

RUN apt update && apt upgrade --yes
RUN apt autoremove --yes

RUN apt remove --yes mysql* mariadb*
RUN apt autoremove --yes

# Install required dependencies
RUN apt install --yes --no-install-suggests --no-install-recommends \
    curl unzip wget vim tree ccze git gnupg

RUN apt install --yes --no-install-suggests --no-install-recommends \
    openssl libssl-dev sudo apt-utils

RUN apt install --yes --no-install-suggests --no-install-recommends \
    build-essential zlib1g-dev libpcre3-dev uuid-dev ca-certificates

# Install ngxpagespeed
RUN /bin/bash -c "$(curl -f -L -sS https://ngxpagespeed.com/install) -y --nginx-version $NGINX_V --additional-nginx-configure-arguments '--with-http_ssl_module --with-http_v2_module --with-http_gzip_static_module --user=nginx --group=nginx --sbin-path=/usr/sbin/nginx --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log'"

RUN useradd --system --no-create-home --user-group nginx

RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

RUN rm -rf $HOME
RUN apt-get purge build-essential -y && apt-get autoremove -y

ENV NGINX_PATH "/usr/local/nginx"
RUN openssl genrsa -out $NGINX_PATH/conf/server.key 1024
RUN openssl req -new -key $NGINX_PATH/conf/server.key -out $NGINX_PATH/conf/server.csr -subj "/C=ES/ST=Bilbao/L=Bizkaia/O=Example Bilbao/CN=examplebilbao.com"
RUN openssl x509 -req -days 365 -in $NGINX_PATH/conf/server.csr -signkey $NGINX_PATH/conf/server.key -out $NGINX_PATH/conf/server.crt

# Limpiar todo
RUN apt autoremove --yes && apt clean
RUN rm -rf /var/lib/apt/lists/*

ADD ./nginx.conf /usr/local/nginx/conf/nginx.conf
ADD ./http.conf /usr/local/nginx/conf/http.conf
ADD ./https.conf /usr/local/nginx/conf/https.conf
ADD ./gzip /usr/local/nginx/conf/gzip
ADD ./mime.types /usr/local/nginx/conf/mime.types
ADD ./pagespeed /usr/local/nginx/conf/pagespeed

# Home
ENV HOME /opt
WORKDIR /opt/symfony

EXPOSE 80
EXPOSE 443

ENTRYPOINT ["/usr/sbin/nginx", "-g", "daemon off;"]
