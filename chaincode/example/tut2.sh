# one representatve for each group
# Materials:http://home.ustc.edu.cn/~zyma/fabric_cn_2.2/
# What is peer and organization https://blog.csdn.net/zhangleisddx/article/details/81410708
####################################################################
# ----------------- Leader Start ----------------------------------#
####################################################################

# login mds6117 account  DO NOT Modify any thing in /etc/resolve.conf
ssh mds6117@[IP]

# login team leader's user account to do rest works

ssh qinwang@[IP] # assume qinwang is your team leader's account

docker ps

cd fabric-dev-servers/
./stopFabric.sh

docker ps
cd ..

# Docker Hub: https://hub.docker.com/u/hyperledger/
curl -sSL http://www.hugoycj.xyz:9980/s/q3WgBQrBjqG5gLR/download/bootstrap.sh| bash -s 1.2.1

vi .profile
    # add this in a new line after the last line in file .profile
    export PATH=~/fabric-samples/bin:$PATH
source ~/.profile

cd fabric-samples
ls -lah

cd chaincode
mkdir -p usedcars/go
cd usedcars/go

wget http://www.hugoycj.xyz:9980/s/6FccQZory5NTyQL/download/userdcars.go -O userdcars.go

ls

vi userdcars.go

cd ../../../first-network

# Modify enviroment
vi docker-compose-cli.yaml
add enviroment - GODEBUG=netdns=go

# Modify enviroment
vi base/peer-base.yaml
add enviroment - GODEBUG=netdns=go

# ./byfn.sh down
# clean containers
docker ps -qa | xargs docker stop
docker ps -qa | xargs docker rm
docker images -a | grep "usedcars" | awk '{print $3}' | xargs docker rmi
# docker rmi --force $(docker images -a -q)

chmod a+x byfn.sh
./byfn.sh generate

# start the first network
./byfn.sh down
./byfn.sh up


#
docker ps
docker ps -a --filter "name=cli"

################################################################
docker exec -it cli bash
#peer chaincode: https://hyperledger-fabric.readthedocs.io/en/release-1.4/commands/peerchaincode.html
peer chaincode list --installed

#####################################
# install usedcars.go on peer0.org1
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
CORE_PEER_ADDRESS=peer0.org1.example.com:7051
CORE_PEER_LOCALMSPID="Org1MSP"
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt

# peer chaincode install -n sacc -p github.com/chaincode/sacc -v 1.3
peer chaincode install -n usedcars -p github.com/chaincode/usedcars/go/ -v 1.0
#####################################
# install usedcars.go on peer1.org1
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
CORE_PEER_ADDRESS=peer1.org1.example.com:7051
CORE_PEER_LOCALMSPID="Org1MSP"
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/tls/ca.crt

peer chaincode install -n usedcars -p github.com/chaincode/usedcars/go/ -v 1.0
#####################################
# install usedcars.go on peer0.org2
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
CORE_PEER_ADDRESS=peer0.org2.example.com:7051
CORE_PEER_LOCALMSPID="Org2MSP"
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt


peer chaincode install -n usedcars -p github.com/chaincode/usedcars/go/ -v 1.0
#####################################
# install usedcars.go on peer1.org2
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
CORE_PEER_ADDRESS=peer1.org2.example.com:7051
CORE_PEER_LOCALMSPID="Org2MSP"
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/tls/ca.crt


peer chaincode install -n usedcars -p github.com/chaincode/usedcars/go/ -v 1.0
#####################################
peer chaincode list --installed

# instantiate usedcars.go on any one and only one peer node
peer chaincode instantiate -o orderer.example.com:7050 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n usedcars -v 1.0 -c '{"Args":["UC0001","Tom","50","Toyota"]}' -P "OR ('Org1MSP.peer','Org2MSP.peer')"

# upgrade
# peer chaincode upgrade -o orderer.example.com:7050 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n sacc -v 1.1 -c '{"Args":["A", "200"]}' -P "OR ('Org1MSP.peer','Org2MSP.peer')"

peer chaincode list --instantiated -C mychannel

################################################################
# ----------------------- Team Leader End --------------------------
####################################################################

################################################################
# ----------------------- Team Member Start --------------------------
####################################################################
# every student(other team members) can operate the following commands
#
ssh alice@[IP]
docker ps
docker exec -it cli bash

# register a used car
peer chaincode invoke -o orderer.example.com:7050 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n usedcars --peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt -c '{"Args":["register","UC0112","Marry","45","Benz"]}'

# peer chaincode invoke -o orderer.example.com:7050 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n sacc --peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt -c '{"Args":["set","A","300"]}'

# query a used car
peer chaincode query -C mychannel -n usedcars -c '{"Args":["query","UC0112"]}'
#peer chaincode query -C mychannel -n usedcars -c '{"Args":["query","UC55891380"]}'


# trade a used car
peer chaincode invoke -o orderer.example.com:7050 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n usedcars --peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt -c '{"Args":["trade","UC0112","Marry","Tina","43"]}'

# query again
peer chaincode query -C mychannel -n usedcars -c '{"Args":["query","UC0112"]}'


#Reconfiguring Your First Network
# the addition of a new organization - Org3 - to the autogenerated application channel - mychannel.
#https://hyperledger-fabric.readthedocs.io/en/v1.1.0-alpha/channel_update.html