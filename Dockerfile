FROM nginx:1.19

RUN apt update && apt upgrade --yes

# Install required dependencies
RUN apt install --yes --no-install-suggests --no-install-recommends \
    curl unzip wget vim tree gnupg libfcgi0ldbl openssl libssl-dev sudo apt-utils zlib1g-dev libpcre3-dev uuid-dev ca-certificates libfcgi-bin

# RUN ln -sf /dev/stdout /var/log/nginx/access.log
# RUN ln -sf /dev/stderr /var/log/nginx/error.log

RUN rm -rf $HOME

ENV NGINX_PATH "/etc/nginx/"
ENV NGINX_PATH_CONFIG $NGINX_PATH"conf.d/"

RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout $NGINX_PATH_CONFIG/server.key -out $NGINX_PATH_CONFIG/server.crt -subj "/C=ES/ST=Bilbao/L=Bizkaia/O=API/CN=localhost"
RUN openssl dhparam -out $NGINX_PATH_CONFIG/server.pem 2048

# Limpiar todo
RUN apt autoremove --yes && apt clean
RUN rm -rf /var/lib/apt/lists/*

ADD nginx.conf   /etc/nginx/nginx.conf
ADD https.conf   /etc/nginx/conf.d/https.conf
ADD gzip         /etc/nginx/conf.d/gzip
ADD mime.types   /etc/nginx/conf.d/mime.types
ADD fastcgi.conf /etc/nginx/conf.d/fastcgi.conf

# Home
ENV HOME /opt
WORKDIR /opt/symfony

EXPOSE 443

ENTRYPOINT ["/usr/sbin/nginx", "-g", "daemon off;"]
