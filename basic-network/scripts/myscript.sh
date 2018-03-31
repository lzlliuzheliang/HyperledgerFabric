#!/bin/bash
set -e
CHANNEL_NAME="$1"
DELAY="$2"
LANGUAGE="$3"
TIMEOUT="$4"
: ${CHANNEL_NAME:="mychannel"}
: ${DELAY:="3"}
: ${LANGUAGE:="golang"}
: ${TIMEOUT:="10"}
LANGUAGE=`echo "$LANGUAGE" | tr [:upper:] [:lower:]`
COUNTER=1
MAX_RETRY=5
ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
CC_SRC_PATH="github.com/fabcar"
. scripts/myutils.sh
createChannel() {
    setGlobals 0 1
#if $CORE-PEER-TLC_ENABLED variable exists and it's value is false
    
    if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
        echo 'no tls create channel'    
        docker exec peer0.org1.example.com peer channel create -o orderer.example.com:7050 -c $CHANNEL_NAME -f /etc/hyperledger/configtx/channel.tx >&log.txt
#peer channel create -o orderer.example.com:7050 -c $CHANNEL_NAME -f ./etc/hyperledger/configtx/channel.tx >&log.txt
        res=$?
                
    else
        echo 'tls create channal'
        docker exec peer0.org1.example.com peer channel create -o orderer.example.com:7050 -c $CHANNEL_NAME -f /etc/hyperledger/configtx/channel.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
        res=$?
       
    fi
    cat log.txt
    verifyResult $res "Channel creation failed"
    echo "===================== Channel \"$CHANNEL_NAME\" is created successfully ===================== "
                echo
}

joinChannel () {
#for org in 1 2; do
    for peer in 0 3; do
        joinChannelWithRetry $peer 1
        echo "===================== peer${peer}.org${org} joined on the channel \"$CHANNEL_NAME\" ===================== "
        sleep $DELAY
        echo
    done
#done
}

## Create channel
echo "Creating channel..."
createChannel

## Join all the peers to the channel
echo "Having all peers join the channel..."
joinChannel

## Set the anchor peers for each org in the channel
echo "Updating anchor peers for org1..."
updateAnchorPeers 0 1   

## Install chaincode on peer0.org1 and peer0.org2
echo "Installing chaincode on peer0.org1..."
installChaincode 0 1
echo "Install chaincode on peer0.org2..."
installChaincode 1 1
echo "Installing chaincode on peer0.org1..."
installChaincode 2 1
echo "Install chaincode on peer0.org2..."
installChaincode 3 1

instantiateChaincode 0 1
instantiateChaincode 1 1
instantiateChaincode 2 1
instantiateChaincode 3 1

chaincodeInvokeInit 0 1

