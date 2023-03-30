#!/bin/bash

DOCKER_PATH="$(dirname $(realpath $0))"
BUILDTEST_DIR="$(realpath ${DOCKER_PATH}/../)/test"
TEST_SYSTEM_DIR="$(realpath ${DOCKER_PATH}/../../)"

if [ ! -d ${BUILDTEST_DIR} ]; then
    echo "Creating test volume: ${BUILDTEST_DIR}"
    mkdir ${BUILDTEST_DIR}
fi

docker run \
	-it \
	--volume ${TEST_SYSTEM_DIR}:/home/docker/action-runner \
	--workdir /home/docker/action-runner \
	mdisdocker
