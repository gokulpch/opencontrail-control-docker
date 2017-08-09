#!/bin/bash
#Install dependencies before proceeding with the other steps 
###yum install kernel-devel kernel-headers nfs-utils socat wget git patch ntp createrepo -y && reboot###
echo "Pulling Contrail Docker Images"
#As contrail-docker images are private using S3 to store specific images
wget https://s3-us-west-2.amazonaws.com/contrail-networking-docker-images/contrail-networking-docker_4.0.0.0-20_trusty.tgz;

echo "Creating a Directory Contrail to store the downloaded packages"
mkdir contrail;
#untar the files
echo "Untar the contrail-networking-docker package"
tar -xvzf contrail-networking-docker_4.0.0.0-20_trusty.tgz -C /root/contrail/.;
mkdir contrail/contrail-docker-images;
echo "Untar the contrail-docker-image package"
#The package contains other dependency packages and the images are located in contrail-docker_images.X.tgz
tar -xvzf contrail/contrail-docker-images_4.0.0.0-20.tgz -C /root/contrail/contrail-docker-images/.;

echo "Installing Latest Docker Version"
sudo yum check-update
#apt-get installs older version of docker when used yum install
curl -fsSL https://get.docker.com/ | sh;
#start docker-engine service
echo "Start Docker Engine"
sudo systemctl start docker;
#check status docker-engine service
echo "Displaying the status of docker"
sudo systemctl status docker;
#enable the docker-engine service
echo "Check Docker Status and Enable the Service"
sudo systemctl enable docker;
#Flush iptables temporarily
iptables --flush;

#Loading Contrail docker images locally on the host
echo "****Loading Contrail Docker Images****"
echo "!!!!This may take 5-7 minutes!!!!"
#Loading Contrail-Controller Image
echo "Loading Contail-Controller image.........."
docker load -i /root/contrail/contrail-docker-images/contrail-controller-ubuntu14.04-4.0.0.0-20.tar.gz;
#Loading Contrail-Analytics Image
echo "Loading Contail-Analytics image.........."
docker load -i /root/contrail/contrail-docker-images/contrail-analytics-ubuntu14.04-4.0.0.0-20.tar.gz;
#Loading Contrail-AnalyticsDB Image
echo "Loading Contail-AnalyticsDB image.........."
docker load -i /root/contrail/contrail-docker-images/contrail-analyticsdb-ubuntu14.04-4.0.0.0-20.tar.gz;
#Use a different file for LB container

echo "****Creating contrailctl directory to create contrail controller and analytics configuration files****"
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
#Provide PF9 Openstack Controller details
admin_password = RbgbcERTb
#Provide PF9 Openstack Controller admin_tenant password
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
#Provide PF9 Openstack Controller details
admin_password = RbgbcERTb
#Provide PF9 Openstack Controller admin_tenant password
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
#Provide PF9 Openstack Controller details
admin_password = RbgbcERTb
#Provide PF9 Openstack Controller admin_tenant password
EOF
