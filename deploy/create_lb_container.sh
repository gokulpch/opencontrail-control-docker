#!/bin/bash
echo "****Creating Contrail Containers***"
echo "Creating load-balancer Container.........."
lb="$(docker images | grep -E 'lb' | awk -e '{print $3}')"
docker run --net=host --cap-add=AUDIT_WRITE --privileged --env='CLOUD_ORCHESTRATOR=openstack' --name=contrail-lb --volume=/etc/contrailctl:/etc/contrailctl -itd $lb
