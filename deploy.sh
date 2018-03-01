export PYTHONIOENCODING=utf8

source ./keys.sh
source ./lib.sh

AWS_EC2_ID="doe"
AWS_EC2_REGION="eu-west-2"
AWS_EC2_SIZE="t2.nano"
AWS_EC2_DISK_GO="20"

create_machine

eval $(docker-machine env $AWS_EC2_ID)
HOST_IP=$(docker-machine ip $AWS_EC2_ID)

update_record bourbaki.doelia.fr $HOST_IP
clone_and_build "go-bourbaki"

update_record whiteboard.doelia.fr $HOST_IP
clone_and_build "realtimeboard"

update_record minelia.doelia.fr $HOST_IP
clone_and_build "minelia"

update_record dominion.doelia.fr $HOST_IP
clone "dominion"
docker build repos/dominion/server -t dominion-server
docker build repos/dominion/client -t dominion-client

docker-compose up -d


