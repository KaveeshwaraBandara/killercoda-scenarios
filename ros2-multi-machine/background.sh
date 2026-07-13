#!/bin/bash
# Provisions TWO ROS 2 containers standing in for the two computers in a real
# robot setup: the robot's Raspberry Pi, and the developer's laptop.
#
# They share a dedicated Docker bridge network, which gives them the thing that
# matters here: two separate machines on one LAN, where ROS 2's automatic
# discovery works exactly as it does over WiFi. (Host networking is NOT used —
# it makes DDS bind to whichever host interface it likes, and discovery breaks.)
set -e

docker pull ros:jazzy
mkdir -p /root/work
docker network create rosnet

for NAME in robot laptop; do
  docker run -d --name "$NAME" --network rosnet \
    -v /root/work:/work -w /work ros:jazzy sleep infinity
  docker exec "$NAME" bash -c "apt-get update -qq && apt-get install -y -qq ros-jazzy-demo-nodes-cpp ros-jazzy-demo-nodes-py"
  # Sourced by LOGIN shells (docker exec bash -lc ...), which is how this
  # scenario runs commands on each machine. Ubuntu's ~/.bashrc bails out early
  # for non-interactive shells, so it can't be used here.
  docker exec "$NAME" bash -c "echo 'source /opt/ros/jazzy/setup.bash' > /etc/profile.d/ros2.sh"
  # ...and by interactive shells, in case a learner opens one to poke around.
  docker exec "$NAME" bash -c "echo 'source /opt/ros/jazzy/setup.bash' >> /root/.bashrc"
done

touch /tmp/ros2-ready
