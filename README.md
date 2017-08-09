# Opencontrail-control-docker Deployment for Integration with Openstack

### Requirements

* CentOS : 7.3.1611, Kernel: 3.10.0-514.el7.x86_64, 3.10.0-514.10.2.el7.x86_64
* Internet connectivity to get required packages
* Contrail Docker Images:  https://s3-us-west-2.amazonaws.com/contrail-networking-docker-images/contrail-networking-docker_4.0.0.0-20_trusty.tgz
* Contrail vRouter Packages: https://s3-us-west-2.amazonaws.com/contrail-networking-docker-images/vrouter-packages_centos.tgz
* Required network connectivity between the hosts


### Topology

#### High Availability

* 3 Hosts : Each host hosting 3 docker containers (1 Contrail-Controller, 1 Contrail-Analytics, 1 Contrail-Analyticsdb)
* 1 Host  : A seperate host for hosting Load_Balancer docker container which acts as the VIP for the contrail_api services, this will be the address provided in openstack_keystone for Contrail intgration with existing openstack
* Computes/vRouter Nodes

#### Single Controller

* 1 Host: This hosts all the three docker containers (1 Contrail-Controller, 1 Contrail-Analytics, 1 Contrail-Analyticsdb)
* Computes/vRouter Nodes

### Contents

* /deploy : shell files with the steps required to deploy Contrail_Control_Plane Components
* /patch : patches required to enable contrail to peer up with Openstack

### Procedure

#### Packages and Dependencies

Install the following packages on all the hosts using YUM :

```
yum install kernel-devel kernel-headers nfs-utils socat wget git patch ntp -y && reboot
```

#### Installation of Contrail Controller, Contrail Analytics, Contrail Analyticsdb

Use 
