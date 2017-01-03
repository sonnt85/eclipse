#!/bin/bash
BRIDGE_NAME=dockersonnt
docker network ls | grep ${BRIDGE_NAME} &>/dev/null || docker network create\
   -o "com.docker.network.bridge.name"="${BRIDGE_NAME}" --subnet=172.18.0.0/16 ${BRIDGE_NAME}
 #      --privileged -v /dev/bus/usb:/dev/bus/usb \
function start_eclipse(){
docker ps -a | grep eclipse || {
      docker pull sonnt/eclipse
      docker run\
      --network ${BRIDGE_NAME}\
      --name eclipse\
      -heclipse\
      --restart always \
      -v /home/sonnt/workspace:/home/sonnt/workspace \
      -v /tmp/.X11-unix:/tmp/.X11-unix\
      --privileged -v /dev:/dev \
      -e DISPLAY=:0\
      -tid sonnt/eclipse nohup /opt/eclipse/eclipse  &>/dev/null&
    }
}
start_eclipse
