######
#Get Contrail-vRouter packages
######
wget https://s3-us-west-2.amazonaws.com/contrail-networking-docker-images/vrouter-packages_centos.tgz;
sleep 10;
######
#Set Contrail Packages
######
mkdir -p /tmp/contrail-vrouter/repo;
tar -xzf /root/vrouter-packages_centos.tgz -C /tmp/contrail-vrouter/repo/;
cd /tmp/contrail-vrouter/repo/vrouter-packages_centos && mv * /tmp/contrail-vrouter/repo/.;
cd;
######
#Removing empty directory
######
rm -rf /tmp/contrail-vrouter/repo/vrouter-packages_centos;
######
#Create a Repo
######
yum install createrepo -y;
createrepo /tmp/contrail-vrouter/repo/;
######
#when using local repo in the target node
######
cat << __EOT__ > /etc/yum.repos.d/contrail-install.repo
[contrail_install_repo]
name=contrail_install_repo
baseurl=file:///tmp/contrail-vrouter/repo/
enabled=1
priority=1
gpgcheck=0
__EOT__
sleep 10;
yum clean all;
##
sleep 5;
yum install yum-plugin-priorities -y;
######
#Install contrail-utilities
######
sleep 5;
yum install contrail-fabric-utils contrail-setup -y;
######
#Install contrail-vrouter
######
sleep 5;
yum install contrail-vrouter-common contrail-vrouter contrail-vrouter-init -y;
######
