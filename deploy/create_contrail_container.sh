#!/bin/bash
echo "****Creating Contrail Containers***"
echo "Creating Contrail-Controller Container.........."
controller="$(docker images | grep -E 'controller' | awk -e '{print $3}')"
docker run --net=host --cap-add=AUDIT_WRITE --privileged --env='CLOUD_ORCHESTRATOR=openstack' --name=contrail-controller --volume=/etc/contrailctl:/etc/contrailctl -itd $controller
echo "Creating Contrail-Analytics Container.........."
analytics="$(docker images | grep -E 'contrail-analytics-ubuntu14.04' | awk -e '{print $3}')"
docker run --net=host --cap-add=AUDIT_WRITE --privileged --env='CLOUD_ORCHESTRATOR=openstack' --name=contrail-analytics --volume=/etc/contrailctl:/etc/contrailctl -itd $analytics
echo "Creating Contrail-AnalyticsDB Container.........."
analyticsdb="$(docker images | grep -E 'analyticsdb' | awk -e '{print $3}')"
docker run --net=host --cap-add=AUDIT_WRITE --privileged --env='CLOUD_ORCHESTRATOR=openstack' --name=contrail-analyticsdb --volume=/etc/contrailctl:/etc/contrailctl -itd $analyticsdb
