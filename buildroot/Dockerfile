FROM centos:7

RUN yum -y install \
    centos-release-openshift-origin14 \
    epel-release

RUN yum -y install \
    docker \
    git \
    python-docker-py \
    python-setuptools \
    e2fsprogs \
    koji \
    python-backports-lzma \
    osbs-client \
    gssproxy \
    fedpkg \
    python-docker-squash \
    atomic-reactor \
    python-atomic-reactor* \
    && yum clean all

CMD ["python", "/usr/bin/atomic-reactor", "--verbose", "inside-build"]