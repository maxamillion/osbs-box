FROM centos:7
MAINTAINER Luiz Carvalho <lucarval@redhat.com>

EXPOSE 8080 8083

COPY yum.repos.d/ /etc/yum.repos.d/

RUN yum -y install epel-release

RUN \
    yum -y install \
        hostname \
        httpd \
        koji-containerbuild-hub \
        koji-hub \
        koji-hub-plugins \
        koji-utils \
        koji-web \
        mod_auth_kerb \
        mod_ssl \
        mod_wsgi \
    && yum clean all

COPY etc/ /etc/
COPY bin/ /usr/local/bin/

RUN chmod +x /usr/local/bin/* && \
    mkdir -p /mnt/koji/{packages,repos,work,scratch} && \
    chown apache.apache /mnt/koji/*

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["httpd", "-D", "FOREGROUND"]
