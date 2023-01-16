# 20
#########################################################
############      in root mode          ############
############ For Team Representatives  ############
#########################################################
# login to root mode, 10.20.14.16 is your assigned IP.Each team is different.
ssh mds6117@10.20.14.16
# swith to root mode
sudo -i 

apt update
#apt upgrade

#creates a new user
adduser alice
# list all of the users using the /etc/passwd File
#cut -d: -f1 /etc/passwd
#less /etc/passwd

# go to folder
cd /home/alice
dpkg --configure -a
# install python
apt-get install python -y
apt-get install python3-distutils
#set default python version
update-alternatives --install /usr/bin/python python /usr/bin/python2 1
update-alternatives --install /usr/bin/python python /usr/bin/python3 2
# download get-pip.py file
#wget https://bootstrap.pypa.io/pip/3.6/get-pip.py
wget https://bootstrap.pypa.io/pip/3.5/get-pip.py

# run get-pip.py
python get-pip.py
# check pip is installed or not. Successfully, if such message appears:"pip 20.3.4 from /usr/local/lib/python3.6/dist-packages/pip python 3.6"
pip --version 
# uninstall requests package
pip uninstall requests -y
# install requests package of version 2.20.1
pip install requests==2.20.1
# uninstall package six
# pip uninstall six -y
# reinstall package six of the updated version
# pip install six==1.16.0

##docker official documentation: https://docs.docker.com/install/linux/docker-ce/ubuntu/
# install packages
apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
# install docker on Ubuntu and add a trusted key to for the docker repository
# curl for data transfer
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
# Verify that you now have the key with the fingerprint 9DC8 5822 9FC7 DD38 854A E2D8 8D81 803C 0EBF CD88,
# by searching for the last 8 characters of the fingerprint. And I also got the same fingerprint.
apt-key fingerprint 0EBFCD88
# Add Apt Repository In Ubuntu
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
# install a few tools
apt-get install docker-ce docker-ce-cli containerd.io

#install docker-compose
pip install docker-compose

#
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
apt-get install -y nodejs

## The build-essential package is a reference for all the packages needed to compile a Debian package.
apt install build-essential

# create new group
# groupadd docker

# list all of the groups
# groups

# add user into group
#gpasswd -a $USER docker
gpasswd -a alice docker

# configures the group membership with which a user wil log in.
newgrp docker
chmod 777 /var/run/docker.sock
# check which groups user belongs togroups alice
#

# check the users in group docker
grep 'docker' /etc/group
#apt install members
#members docker

##################################################################
# Add new users
# Repeat below part if you want to add more users
##################################################################
#creates a new user
adduser bob
# list all of the users using the /etc/passwd File
#cut -d: -f1 /etc/passwd
#less /etc/passwd

# add user into group
#gpasswd -a $USER docker
gpasswd -a bob docker

# configures the group membership with which a user wil log in.
newgrp docker

# check which groups user belongs to
#groups cityu

# check the users in group docker
grep 'docker' /etc/group

# apt install members
# members docker
# Repeat above part to add all your team members.
# Team Leader's task completed. Please close the terminal. 
# ------------------------ Root Mode End -------------------------------------
###############################################################################
###############################################################################
###############################################################################
############################################
############ in alice user-mode  ##########
############################################
# login to alice user-mode, 10.20.14.16 is your assigned IP. Each team is different.
ssh alice@10.20.14.16
# create a new folder
mkdir ~/.npm-global
# Add the path in npm configure file
npm config set prefix '~/.npm-global'
# Accelerate NPM install speed
npm config set registry https://registry.npm.taobao.org
#nano .profile:
vi .profile
	##In the last line insert the following command
    export PATH=~/.npm-global/bin:$PATH
# excute
source ~/.profile

############
##It might take a while...
npm install -g yo
#npm install -g yo@2.0.5
#https://www.npmjs.com/package/yo

# composer
npm cache verify
npm install -g composer-cli@0.20
npm install -g composer-rest-server@0.20
npm install -g generator-hyperledger-composer@0.20
# require sometime
npm install -g composer-playground@0.20

#list npm user installed packages
npm list -g --depth=0

#
mkdir ~/fabric-dev-servers && cd ~/fabric-dev-servers
# download scripts
curl -O http://www.hugoycj.xyz:9980/s/Q6cQMJxKkAM2AZ3/download/fabric-dev-servers.tar.gz
tar -xvf fabric-dev-servers.tar.gz

# Claim the version
export FABRIC_VERSION=hlfv12
./downloadFabric.sh

# Claim the version
export FABRIC_VERSION=hlfv12
./startFabric.sh

# list all the composer card
composer card list

# Create PeerAdminCard
./createPeerAdminCard.sh

composer card list

# Background
composer-playground
# nohup composer-playground -d &
# nohup composer-playground -p [PortNumber] -d &
# nohup composer-playground -p 8080 -d &
# then two more ENTERs
