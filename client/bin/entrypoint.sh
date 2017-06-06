#!/bin/bash
set -xeuo pipefail

rm -rf /root/{.koji,bin}
mkdir -p /root/{.koji,bin}

ln -s /opt/koji-clients/kojiadmin/config /root/.koji/config

set +xe
echo "Waiting for koji-hub to start..."
while true; do
    koji hello && break
	sleep 5
done
set -xe

# TODO: Just create directly in DB?
koji add-tag build --arches=x86_64
koji add-tag dest --arches=x86_64
koji add-target candidate build dest

koji add-pkg dest osbs-buildroot-docker --owner kojiadmin

# Enable content generator access
koji grant_cg_access kojiadmin atomic-reactor
# TODO: Create a channel

# For accessing containers not part of the default network
WORKSTATION_IP=$(/sbin/ip route | awk '/default/ { print $3 }')

ln -s /opt/osbs/osbs.conf /etc/osbs.conf
oc login --insecure-skip-tls-verify=true -u osbs -p osbs https://${WORKSTATION_IP}:8443/
# Some of the commands below require user to be a cluster admin
# In the future, this project should provide an ansible playbook
# that uses the existing ansible role osbs-namespace to perform such operations.
# Although, secret is probably better handled here.
# In the meantime, just make osbs user a cluster admin
# (can be done prior to user and namespace are created):
#   oc -n osbs adm policy add-cluster-role-to-user cluster-admin osbs
oc new-project osbs
oc adm policy add-role-to-user edit -z builder

oc secret new kojisecret \
    serverca=/opt/koji-clients/kojiadmin/serverca.crt \
    ca=/opt/koji-clients/kojiadmin/clientca.crt \
    cert=/opt/koji-clients/kojiadmin/client.crt

oc secrets add serviceaccount/builder secrets/kojisecret --for=mount

oc create policybinding osbs

oc create -f - << EOF
apiVersion: v1
kind: Role
metadata:
  name: osbs-custom-build
rules:
  - verbs:
    - create
    resources:
    - builds/custom
EOF

oc adm policy add-role-to-user osbs-custom-build osbs -z builder --role-namespace osbs

token=$(oc whoami -t)
sed --follow-symlinks -i "s/OSBS_TOKEN/${token}/" /etc/osbs.conf
# Use workstation's IP so it's reachable from within openshift's pods
sed --follow-symlinks -i "s/KOJI_HUB_IP/${WORKSTATION_IP}/" /etc/osbs.conf
sed --follow-symlinks -i "s/OPENSHIFT_IP/${WORKSTATION_IP}/" /etc/osbs.conf

exec "$@"
