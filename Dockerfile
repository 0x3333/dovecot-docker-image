FROM alpine:3.6

MAINTAINER Instrumentisto Team <developer@instrumentisto.com>


# Build and install Dovecot
# https://git.alpinelinux.org/cgit/aports/tree/main/dovecot/APKBUILD?h=5dac5caa8e9bba5534fd9d4010ddc8955eddb194
RUN apk update \
 && apk upgrade \
 && apk add --no-cache \
        ca-certificates \
 && update-ca-certificates \

 # Install Dovecot dependencies
 && apk add --no-cache \
        libressl libressl2.5-libcrypto libressl2.5-libssl \
        libbz2 zlib \
        libcap \
        libpq mariadb-client-libs sqlite-libs \
        libldap \
        heimdal-libs \

 # Install tools for building
 && apk add --no-cache --virtual .tool-deps \
        curl coreutils autoconf g++ libtool make \

 # Install Dovecot build dependencies
 && apk add --no-cache --virtual .build-deps \
        libressl-dev \
        bzip2-dev zlib-dev \
        libcap-dev \
        postgresql-dev mariadb-dev sqlite-dev \
        openldap-dev \
        heimdal-dev \
        linux-headers \

 # Download and prepare Dovecot sources
 && curl -fL -o /tmp/dovecot.tar.gz \
         https://www.dovecot.org/releases/2.2/dovecot-2.2.27.tar.gz \
 && (echo "faab441bb2afa1e6de3e6ec6207c92a333773941bbc10c4761483ef6ccc193d3a4983de1acc73325122c22b197ea25c1e54886cccfb6b060ede90936a69b71f2  /tmp/dovecot.tar.gz" \
         | sha512sum -c -) \
 && tar -xzf /tmp/dovecot.tar.gz -C /tmp/ \
 && cd /tmp/dovecot-* \
 && curl -fL -o ./libressl.patch \
         https://git.alpinelinux.org/cgit/aports/plain/main/dovecot/libressl.patch?h=5dac5caa8e9bba5534fd9d4010ddc8955eddb194 \
 && patch -p1 -i ./libressl.patch \

 # Build Dovecot from sources
 && ./configure --prefix=/usr \
                --with-ssl=openssl --with-ssldir=/etc/ssl/dovecot \
                --with-sql=plugin --with-pgsql --with-mysql --with-sqlite \
                --with-ldap=plugin \
                --with-gssapi=plugin \
                --with-rundir=/run/dovecot \
                --localstatedir=/var \
                --sysconfdir=/etc \
                # No documentation included to keep image size smaller
                --mandir=/tmp/man \
                --docdir=/tmp/doc \
                --infodir=/tmp/info \
 && make \

 # Create Dovecot user and groups
 && addgroup -S -g 91 dovecot \
 && adduser -S -u 90 -D -s /sbin/nologin \
            -H -h /dev/null \
            -G dovecot -g dovecot \
            dovecot \
 && addgroup -S -g 93 dovenull \
 && adduser -S -u 92 -D -s /sbin/nologin \
            -H -h /dev/null \
            -G dovenull -g dovenull \
            dovenull \

 # Install and configure Dovecot
 && make install \
 && rm -rf /etc/dovecot/* \
 && mv /tmp/doc/example-config/dovecot* \
       /tmp/doc/example-config/conf.d \
       /tmp/doc/dovecot-openssl.cnf \
       /etc/dovecot/ \
 # Set logging to STDOUT/STDERR
 && sed -i -e 's,#log_path = syslog,log_path = /dev/stderr,' \
           -e 's,#info_log_path =,info_log_path = /dev/stdout,' \
           -e 's,#debug_log_path =,debug_log_path = /dev/stdout,' \
        /etc/dovecot/conf.d/10-logging.conf \
 # Set default passdb to passwd and create appropriate 'users' file
 && sed -i -e 's,!include auth-system.conf.ext,!include auth-passwdfile.conf.ext,' \
           -e 's,#!include auth-passwdfile.conf.ext,#!include auth-system.conf.ext,' \
        /etc/dovecot/conf.d/10-auth.conf \
 && install -m 640 -o dovecot -g mail /dev/null \
            /etc/dovecot/users \
 # Change ssl dirs in default config and generate default certs
 && sed -i -e 's,^ssl_cert =.*,ssl_cert = </etc/ssl/dovecot/server.pem,' \
           -e 's,^ssl_key =.*,ssl_key = </etc/ssl/dovecot/server.key,' \
        /etc/dovecot/conf.d/10-ssl.conf \
 && install -d /etc/ssl/dovecot \
 && openssl req -new -x509 -nodes -days 365 \
                -config /etc/dovecot/dovecot-openssl.cnf \
                -out /etc/ssl/dovecot/server.pem \
                -keyout /etc/ssl/dovecot/server.key \
 && chmod 0600 /etc/ssl/dovecot/server.key \

 # Cleanup unnecessary stuff
 && apk del .tool-deps .build-deps \
 && rm -rf /var/cache/apk/* \
           /tmp/*


EXPOSE 110 143 993 995

CMD ["/usr/sbin/dovecot", "-F"]
