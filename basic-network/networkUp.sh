# CLI_TIMEOUT=10
# # default for delay between commands
# CLI_DELAY=3
# # channel name defaults to "mychannel"
# CHANNEL_NAME="mychannel"
# # use this as the default docker-compose yaml definition
# COMPOSE_FILE=docker-compose.yaml
# # use golang as the default language for chaincode
# LANGUAGE=golang
# # default image tag
# IMAGETAG="latest"
# TIMEOUT=300
#CHANNEL_NAME=mychannel TIMEOUT=60 docker-compose -f docker-compose.yml up -d
docker exec cli ./scripts/myscript.sh $CHANNEL_NAME $CLI_DELAY $LANGUAGE $CLI_TIMEOUT