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

#This is for a LB container which is only required on the Host with LB
echo "Loading Contail-LB image.........."
docker load -i /root/contrail/contrail-docker-images/contrail-lb-ubuntu14.04-4.0.0.0-20.tar.gz;


cho "****Creating contrailctl directory to create contrail controller and analytics configuration files****"
mkdir /etc/contrailctl;

echo "****Creating controller configuration file***"
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
