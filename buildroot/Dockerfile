FROM fedora:25

RUN dnf -y update && dnf clean all

RUN dnf -y install \
    docker \
    git \
    e2fsprogs \
    koji \
    osbs-client \
    gssproxy \
    fedpkg \
    atomic-reactor \
    && dnf clean all

CMD ["/usr/bin/atomic-reactor", "--verbose", "inside-build"]