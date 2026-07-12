#!/bin/bash
# Runs in the background while the learner reads the intro.
# Provisions a ROS 2 Jazzy container with the talker/listener demo nodes.
set -e

docker pull ros:jazzy
docker run -d --name ros2 ros:jazzy sleep infinity
docker exec ros2 bash -c "apt-get update -qq && apt-get install -y -qq ros-jazzy-demo-nodes-cpp ros-jazzy-demo-nodes-py"
docker exec ros2 bash -c "echo 'source /opt/ros/jazzy/setup.bash' >> /root/.bashrc"

# Step 1 polls for this flag before letting the learner continue.
touch /tmp/ros2-ready
