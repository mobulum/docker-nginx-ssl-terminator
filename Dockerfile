FROM phusion/baseimage:latest

ENV HOME /root
ENV DEBIAN_FRONTEND noninteractive
ENV DEBIAN_PRIORITY critical
ENV DEBCONF_NOWARNINGS yes
ENV INITRD No


RUN mkdir -p /etc/ssl/nginx

RUN \
    sed -i 's/^# \(.*-backports\s\)/\1/g' /etc/apt/sources.list && \
    apt-get update -qqy && \
    apt-get install -qqy wget curl apt-transport-https libcurl3-gnutls && \
    wget -O - http://nginx.org/keys/nginx_signing.key | apt-key add - && \
    wget -O - https://download.newrelic.com/548C16BF.gpg | apt-key add - && \
    echo "deb http://nginx.org/packages/mainline/ubuntu/ trusty nginx" | tee -a /etc/apt/sources.list && \
    echo "deb-src http://nginx.org/packages/mainline/ubuntu/ trusty nginx" | tee -a /etc/apt/sources.list && \
    echo "deb http://apt.newrelic.com/debian/ newrelic non-free" | tee -a /etc/apt/sources.list && \
    apt-get update -qqy

RUN \
    apt-get install -qqy \
        nginx \
        nginx-nr-agent \
        newrelic-sysmond

ADD bin/newrelic.sh /etc/my_init.d/10_setup_newrelic.sh
ADD bin/start /usr/local/bin/start

# Configure no init scripts to run on package updates.
ADD bin/policy-rc.d /usr/sbin/policy-rc.d

# Disable SSH
RUN rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh

RUN \
    chmod +x /etc/my_init.d/10_setup_newrelic.sh; \
    rm -f /etc/nginx/sites-enabled/default

# Remove the default Nginx configuration file
RUN rm -v /etc/nginx/nginx.conf

WORKDIR /usr/local/bin

# Nginx Installation
ENV NEWRELIC_LICENSE false
ENV NEWRELIC_APP false
ENV SYSLOG_SERVER_HOST false
ENV TLS_SERVER_KEY_NAME false
ENV TLS_SERVER_CRT_NAME false
ENV UPSTREAM_URL localhost:80
ENV SERVER_NAME example.com

# Copy a configuration file from the current directory
COPY nginx.conf /etc/nginx/nginx.conf

RUN mkdir -p /etc/nginx/tls

COPY default.conf.source /etc/nginx/sites-enabled/default.conf.source
RUN cat /etc/nginx/sites-enabled/default.conf.source

CMD ["/sbin/my_init", "--", "bash", "/usr/local/bin/start"]

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

