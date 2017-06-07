FROM centos:7
MAINTAINER Luiz Carvalho <lucarval@redhat.com>

COPY yum.repos.d/ /etc/yum.repos.d/

RUN yum install -y \
    centos-release-openshift-origin13 \
    epel-release

RUN yum install -y \
    origin-clients \
    iproute \
    koji-containerbuild-cli \
    koji \
    && yum clean all

ADD bin/ /usr/local/bin/

RUN chmod +x /usr/local/bin/*

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["sleep", "infinity"]
