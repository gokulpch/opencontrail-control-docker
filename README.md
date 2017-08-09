# Opencontrail-control-docker Deployment for Integration with Openstack

### Requirements

* CentOS : 7.3.1611, Kernel: 3.10.0-514.el7.x86_64, 3.10.0-514.10.2.el7.x86_64
* Internet connectivity to get required packages
* Contrail Docker Images:  https://s3-us-west-2.amazonaws.com/contrail-networking-docker-images/contrail-networking-docker_4.0.0.0-20_trusty.tgz
* Contrail vRouter Packages: https://s3-us-west-2.amazonaws.com/contrail-networking-docker-images/vrouter-packages_centos.tgz
* Required network connectivity between the hosts
* Root access to the hosts


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

###### Shell scripts with installation steps

* Run from /root

1. Installs Docker, Pulls the required images, Load the images, Create sample conf files in /etc/contrailctl (this doesnt include contrail_lb container):

   wget https://raw.githubusercontent.com/gokulpch/opencontrail-control-docker/master/deploy/provision_contrail_centos.sh

2. Creates the containers (fill all the configuration files in /etc/contrailctl before running these commands):

   wget https://raw.githubusercontent.com/gokulpch/opencontrail-control-docker/master/deploy/create_contrail_container.sh
   
3. Provisions only LB container, Docker (HA) on a seperate host/vm:

   wget https://raw.githubusercontent.com/gokulpch/opencontrail-control-docker/master/deploy/provision_contrail_lb_centos.sh

4. Creates only LB container (after step 3):

   wget https://raw.githubusercontent.com/gokulpch/opencontrail-control-docker/master/deploy/create_lb_container.sh
   
5. Provisions Compute/vRouter node with all the packages required for the vRouter:

   wget https://raw.githubusercontent.com/gokulpch/opencontrail-control-docker/master/deploy/provision_vrouter_centos.sh

#### Packages and Dependencies

###### Install the following packages on all the hosts using YUM :

```
yum install kernel-devel kernel-headers nfs-utils net-tools socat wget git patch ntp -y && reboot
```

###### Install Docker on the nodes where Contrail containers are installed:

```
sudo yum check-update

#apt-get installs older version of docker when used yum install

curl -fsSL https://get.docker.com/ | sh;

#start docker-engine service

sudo systemctl start docker;

#check status docker-engine service

sudo systemctl status docker;

#enable the docker-engine service

sudo systemctl enable docker;

```

#### Installation of Contrail Controller, Contrail Analytics, Contrail Analyticsdb

###### Get the required docker-images:

wget https://s3-us-west-2.amazonaws.com/contrail-networking-docker-images/contrail-networking-docker_4.0.0.0-20_trusty.tgz;

###### Untar the archive and arrange the packages in a directory

```
mkdir contrail;

#untar the files

tar -xvzf contrail-networking-docker_4.0.0.0-20_trusty.tgz -C /root/contrail/.;

mkdir contrail/contrail-docker-images;

tar -xvzf contrail/contrail-docker-images_4.0.0.0-20.tgz -C /root/contrail/contrail-docker-images/.;

```

###### Load the docker images

```
#Loading Contrail docker images locally on the host

#Loading Contrail-Controller Image
docker load -i /root/contrail/contrail-docker-images/contrail-controller-ubuntu14.04-4.0.0.0-20.tar.gz;

#Loading Contrail-Analytics Image
docker load -i /root/contrail/contrail-docker-images/contrail-analytics-ubuntu14.04-4.0.0.0-20.tar.gz;

#Loading Contrail-AnalyticsDB Image
docker load -i /root/contrail/contrail-docker-images/contrail-analyticsdb-ubuntu14.04-4.0.0.0-20.tar.gz;

```

###### Create contrailctl directory to create contrail controller and analytics configuration files (This will be mounted to the containers)

```
mkdir /etc/contrailctl;

echo "****Creating controller configuration file***"
cat > /etc/contrailctl/controller.conf << EOF
#Use ctrl/data (int-cloud) if using seperate networks for provisioning/ssh for all the contrail ctrl-plane components
[GLOBAL]
#Replace with all the compute nodes IP addresses
compute_nodes = 10.87.1.44,10.87.1.45
enable_webui_service = True
cloud_orchestrator = openstack
#Replace with LB_IP address
config_ip = 10.87.1.43
#Replace with all the analytics_db IP addresses
analyticsdb_nodes = 10.87.1.40,10.87.1.41,10.87.1.42
#Replace with all the Analytics IP addresses
analytics_nodes = 10.87.1.40,10.87.1.41,10.87.1.42
sandesh_ssl_enable = False
introspect_ssl_enable = False
controller_nodes = 10.87.1.40,10.87.1.41,10.87.1.42
enable_control_service = True
ceph_controller_nodes =
enable_config_service = True
#Replace with LB_IP address
analytics_ip = 10.87.1.43
#Replace with LB_IP address
controller_ip = 10.87.1.43
#Replace with all the Config IP addresses
config_nodes = 10.87.1.40,10.87.1.41,10.87.1.42
[CONTROLLER]
external_routers_list = {}
[WEBUI]
webui_storage_enable = False
[KEYSTONE]
ip = 50.50.23.14
#Provide Openstack Controller details
admin_password = RbgbcERTb
#Provide Openstack Controller admin_tenant password
EOF

echo "****Creating analytics configuration file***"
cat > /etc/contrailctl/analytics.conf << EOF
#Use ctrl/data (int-cloud) if using seperate networks for provisioning/ssh for all the contrail ctrl-plane components
[GLOBAL]
#Replace with all the compute nodes IP addresses
compute_nodes = 10.87.1.44,10.87.1.45
enable_webui_service = True
cloud_orchestrator = openstack
#Replace with LB_IP address
config_ip = 10.87.1.43
#Replace with all the analytics_db IP addresses
analyticsdb_nodes = 10.87.1.40,10.87.1.41,10.87.1.42
#Replace with all the Analytics IP addresses
analytics_nodes = 10.87.1.40,10.87.1.41,10.87.1.42
sandesh_ssl_enable = False
introspect_ssl_enable = False
#Replace with all the Controllers IP addresses
controller_nodes = 10.87.1.40,10.87.1.41,10.87.1.42
enable_control_service = True
ceph_controller_nodes =
enable_config_service = True
#Replace with LB_IP address
analytics_ip = 10.87.1.43
#Replace with LB_IP address
controller_ip = 10.87.1.43
#Replace with all the Config IP addresses
config_nodes = 10.87.1.40,10.87.1.41,10.87.1.42
[KEYSTONE]
ip = 50.50.23.14
#Provide Openstack Controller details
admin_password = RbgbcERTb
#Provide Openstack Controller admin_tenant password
EOF


echo "****Creating analyticsdb configuration file***"
cat > /etc/contrailctl/analyticsdb.conf << EOF
#Use ctrl/data (int-cloud) if using seperate networks for provisioning/ssh for all the contrail ctrl-plane components
[GLOBAL]
#Replace with all the compute nodes IP addresses
compute_nodes = 10.87.1.44,10.87.1.45
enable_webui_service = True
cloud_orchestrator = openstack
#Replace with LB_IP address
config_ip = 10.87.1.43
#Replace with all the analytics_db IP addresses
analyticsdb_nodes = 10.87.1.40,10.87.1.41,10.87.1.42
#Replace with all the Analytics IP addresses
analytics_nodes = 10.87.1.40,10.87.1.41,10.87.1.42
sandesh_ssl_enable = False
introspect_ssl_enable = False
#Replace with all the Controllers IP addresses
controller_nodes = 10.87.1.40,10.87.1.41,10.87.1.42
enable_control_service = True
ceph_controller_nodes =
enable_config_service = True
#Replace with LB_IP address
analytics_ip = 10.87.1.43
#Replace with LB_IP address
controller_ip = 10.87.1.43
#Replace with all the Config IP addresses
config_nodes = 10.87.1.40,10.87.1.41,10.87.1.42
[KEYSTONE]
ip = 50.50.23.14
#Provide Openstack Controller details
admin_password = RbgbcERTb
#Provide Openstack Controller admin_tenant password
EOF

```

###### In case of HA cluster use a seperate Host/VM for the LB Container

Load the LB docker image:

```
docker load -i /root/contrail/contrail-docker-images/contrail-lb-ubuntu14.04-4.0.0.0-20.tar.gz;

```

```
cat > /etc/contrailctl/lb.conf << EOF
#Use ctrl/data (int-cloud) if using seperate networks for provisioning/ssh for all the contrail ctrl-plane components
[HAPROXY_TORAGENT]
haproxy_toragent_config = {}
[GLOBAL]
#Replace with all the compute nodes IP addresses
compute_nodes = 10.87.1.44,10.87.1.45
enable_webui_service = True
sandesh_ssl_enable = False
cloud_orchestrator = openstack
enable_config_service = True
#Replace with all the config nodes IP addresses
config_nodes = 10.87.1.40,10.87.1.41,10.87.1.42
#Replace with LB_IP address
config_ip = 10.87.1.43
#Replace with all the analytics_db IP addresses
analyticsdb_nodes = 10.87.1.40,10.87.1.41,10.87.1.42
enable_control_service = True
introspect_ssl_enable = False
#Replace with all the Controllers IP addresses
controller_nodes = 10.87.1.40,10.87.1.41,10.87.1.42
#Replace with all the Analytics IP addresses
analytics_nodes = 10.87.1.40,10.87.1.41,10.87.1.42
ceph_controller_nodes =
#Replace with LB_IP address
analytics_ip = 10.87.1.43
#Replace with LB_IP address
controller_ip = 10.87.1.43
EOF

```

###### Create Containers

```
#Controller:

controller="$(docker images | grep -E 'controller' | awk -e '{print $3}')"
docker run --net=host --cap-add=AUDIT_WRITE --privileged --env='CLOUD_ORCHESTRATOR=openstack' --name=contrail-controller --volume=/etc/contrailctl:/etc/contrailctl -itd $controller

#Analytics:

analytics="$(docker images | grep -E 'contrail-analytics-ubuntu14.04' | awk -e '{print $3}')"
docker run --net=host --cap-add=AUDIT_WRITE --privileged --env='CLOUD_ORCHESTRATOR=openstack' --name=contrail-analytics --volume=/etc/contrailctl:/etc/contrailctl -itd $analytics

#AnalyticsDB:

analyticsdb="$(docker images | grep -E 'analyticsdb' | awk -e '{print $3}')"
docker run --net=host --cap-add=AUDIT_WRITE --privileged --env='CLOUD_ORCHESTRATOR=openstack' --name=contrail-analyticsdb --volume=/etc/contrailctl:/etc/contrailctl -itd $analyticsdb

# Load-Balancer:

lb="$(docker images | grep -E 'lb' | awk -e '{print $3}')"
docker run --net=host --cap-add=AUDIT_WRITE --privileged --env='CLOUD_ORCHESTRATOR=openstack' --name=contrail-lb --volume=/etc/contrailctl:/etc/contrailctl -itd $lb
```

###### Change the neccessary parameters of contrail to function with existing Openstack

* In case of HA cluster all the changes should be done on all the contrail containers

1. VNC_AUTH

Login to Contrail-Controller Docker Container:
```
 docker exec -it contrail-controller bash
```

Copy the snippet below and use patch to apply the changes (patch -p1 < vnc_patch)

```
--- /usr/lib/python2.7/dist-packages/vnc_cfg_api_server/vnc_auth_keystone.py    2017-06-04 20:22:00.000000000 +0000
+++ vnc_auth_keystone.py    2017-07-26 22:57:34.659274000 +0000
@@ -144,7 +144,7 @@
             if args.keyfile and args.certfile:
                 certs=[args.certfile, args.keyfile, args.cafile]
             _kscertbundle=cfgmutils.getCertKeyCaBundle(_DEFAULT_KS_CERT_BUNDLE,certs)
-        identity_uri = '%s://%s:%s' % (args.auth_protocol, args.auth_host, args.auth_port)
+        identity_uri = '%s://%s:%s/keystone' % (args.auth_protocol, args.auth_host, args.auth_port)
         self._conf_info = {
             'auth_host': args.auth_host,
             'auth_port': args.auth_port,
```

2. Web_Auth

```
--- /usr/src/contrail/contrail-web-core/src/serverroot/orchestration/plugins/openstack/keystone.api.js    2017-06-04 20:21:59.000000000 +0000
+++ keystone.api.js    2017-07-26 23:04:30.891704930 +0000
@@ -214,6 +214,7 @@
     if (null != tmpAuthRestObj.mapped) {
         headers['protocol'] = tmpAuthRestObj.mapped.protocol;
     }
+    reqUrl = "/keystone" + reqUrl;
     tmpAuthRestObj.authRestAPI.api.post(reqUrl, postData, function(error, data) {
         if (null != error) {
             logutils.logger.error('authPostV2Req() error:' + error);
@@ -259,6 +260,7 @@
     }

     tmpAuthRestObj.authRestAPI.api.get(reqUrl, function(error, data) {
+    reqUrl = "/keystone" + reqUrl;
         if (null != error) {
             logutils.logger.error('getAuthResponse() error:' + error);
         }
```

3. Change the Keystone authentication and other auth files as needed

/etc/contrail/contrail-keystone-auth.conf
```
[KEYSTONE]
auth_url=https://juniper.cosnet.net/keystone/v2.0
auth_host=juniper.cosnet.net
auth_protocol=https
auth_port=443
admin_user=admin@cosnet.net
admin_password=lZbye761Uq
admin_tenant_name=admin
memcache_servers=127.0.0.1:11211
;insecure=False
;certfile=/etc/contrail/ssl/certs/keystone.pem
;keyfile=/etc/contrail/ssl/certs/keystone.pem
;cafile=/etc/contrail/ssl/certs/keystone_ca.pem

```
/etc/contrail/contrail-api.conf

```
aaa_mode = no-auth

```

/etc/contrail/config.global.js

```
config.identityManager.port = '443';
config.identityManager.authProtocol = 'https';

```

/etc/contrail/contrail-webui-userauth.js

```
auth.admin_tenant_name = 'admin@cosnet.net';

```

###### Restart Services on the Controller to make the above changes Effective

* service contrail-api restart
* service contrail-webui restart

###### Change 'aaa' mode on the analytics controllers to use no_auth for analytics 

Login to Contrail-Analytics Docker Container:

```
 docker exec -it contrail-analytics bash
```

/etc/contrail/contrail-analytics-api.conf

```
aaa_mode = no-auth

```
Restart analytics_api

* service contrail-analytics-api restart


### Installing vRouter

1. Get the required packages

wget https://s3-us-west-2.amazonaws.com/contrail-networking-docker-images/vrouter-packages_centos.tgz;

2. Set and un-archive the packages

```
mkdir -p /tmp/contrail-vrouter/repo;
tar -xzf /root/vrouter-packages_centos.tgz -C /tmp/contrail-vrouter/repo/;
cd /tmp/contrail-vrouter/repo/vrouter-packages_centos && mv * /tmp/contrail-vrouter/repo/.;
cd;
```
3. Create a Repo

```
yum install createrepo -y;
createrepo /tmp/contrail-vrouter/repo/;
```

4. Create a local repo configuration

```
cat << __EOT__ > /etc/yum.repos.d/contrail-install.repo
[contrail_install_repo]
name=contrail_install_repo
baseurl=file:///tmp/contrail-vrouter/repo/
enabled=1
priority=1
gpgcheck=0
__EOT__

```

5. yum clean all

6. yum install yum-plugin-priorities -y

7. yum install contrail-fabric-utils contrail-setup -y

8. yum install contrail-vrouter-common contrail-vrouter contrail-vrouter-init -y

9. Initiate provisioning on the vRouter nodes:

```
  contrail-compute-setup --self_ip 10.87.1.45\
                         --hypervisor libvirt\
                         --cfgm_ip 10.87.1.40,10.87.1.41,10.87.1.42\
                         --collectors 10.87.1.40,10.87.1.41,10.87.1.42\
                         --control-nodes 10.87.1.40,10.87.1.41,10.87.1.42\
                         --keystone_ip 50.50.20.14\
                         --keystone_auth_protocol https\
                         --keystone_auth_port 443\
                         --keystone_admin_user admin\
                         --keystone_admin_password 761Uq\
                         --keystone_admin_tenant_name admin\
```

10. Reboot the nodes to apply the kernal changes

###### Registering Components with Contrail

```
#vRouter:

python /usr/share/contrail-utils/provision_vrouter.py --api_server_ip 10.87.29.133 --host_name kubenode --host_ip 10.87.29.132 --oper add

# Analytics:

python /usr/share/contrail-utils/provision_analytics_node.py --api_server_ip 10.87.120.44 --host_name kube-setup-1 --host_ip 10.87.120.39 --oper add

# Analytics DB:

python /usr/share/contrail-utils/provision_database_node.py --api_server_ip 10.87.120.44 --host_name kube-setup-1 --host_ip 10.87.120.39 --oper add

```
