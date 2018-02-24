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
build_docker_app "go-bourbaki"

update_record whiteboard.doelia.fr $HOST_IP
build_docker_app "realtimeboard"

docker-compose up -d



