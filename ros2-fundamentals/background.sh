#!/bin/bash
# Provisions ROS 2 Jazzy while the learner reads the intro.
# (Killercoda's host image is older than Ubuntu 24.04, so ROS 2 Jazzy runs in
# a container — the same ros:jazzy image the course uses everywhere else.)
set -e

docker pull ros:jazzy
# /work is shared with the host so learners can also use the editor tab.
mkdir -p /root/work
docker run -d --name ros2 -v /root/work:/work -w /work ros:jazzy sleep infinity
docker exec ros2 bash -c "apt-get update -qq && apt-get install -y -qq ros-jazzy-demo-nodes-cpp ros-jazzy-demo-nodes-py"
docker exec ros2 bash -c "echo 'source /opt/ros/jazzy/setup.bash' >> /root/.bashrc"

touch /tmp/ros2-ready
