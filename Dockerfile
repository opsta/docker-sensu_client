# Sensu Client
#
# Monitor servers, services, application health, and business KPIs
# This is Sensu Client Docker Image

FROM opsta/sensu-base:1.0-xenial-20160923.1
MAINTAINER Jirayut Nimsaeng <jirayut [at] opsta.io>

# 1) Install required package for Sensu Client Plugins
# 2) Install Sensu Client Plugins
# 3) Remove packages and files to reduce Docker Image
ENV PATH=/opt/sensu/embedded/bin:$PATH \
    GEM_PATH=/opt/sensu/embedded/lib/ruby/gems/2.0.0:$GEM_PATH
ARG APT_CACHER_NG
RUN [ -n "$APT_CACHER_NG" ] && \
      echo "Acquire::http::Proxy \"$APT_CACHER_NG\";" \
      > /etc/apt/apt.conf.d/11proxy || true; \
    apt-get update && \
    apt-get install -y bc build-essential libmysqlclient-dev libsasl2-dev && \
    sensu-install -P disk-checks,process-checks,cpu-checks,memory-checks, \
      mysql,http,load-checks,mongodb,docker,network-checks,redis, \
      filesystem-checks,execute && \
    apt-get remove --purge --auto-remove -y \
      build-essential ifupdown iproute2 isc-dhcp-client isc-dhcp-common \
      libatm1 libisc-export160 libmnl0 libxtables11 manpages netbase \
      libmysqlclient-dev libsasl2-dev && \
    apt-get -y autoremove && \
    apt-get clean && \
    rm -rf /usr/lib/x86_64-linux-gnu/libfakeroot /var/lib/apt/lists/* \
      /etc/apt/apt.conf.d/11proxy \
      /opt/sensu/embedded/lib/ruby/gems/2.2.0/cache/*

EXPOSE 3030
CMD ["/opt/sensu/embedded/bin/ruby", "/opt/sensu/bin/sensu-client", \
     "-c", "/etc/sensu/config.json", "-d", "/etc/sensu/conf.d", \
     "-e", "/etc/sensu/extensions"]
