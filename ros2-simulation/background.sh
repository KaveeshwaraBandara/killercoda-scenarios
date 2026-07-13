#!/bin/bash
# Provisions ROS 2 Jazzy + Gazebo Harmonic while the learner reads the intro.
# Installs only the two ros_gz packages the scenario needs (ros-gz-sim for the
# simulator, ros-gz-bridge for the ROS<->Gazebo translation) — the full ros-gz
# metapackage pulls in image/OpenCV deps this scenario never uses.
set -e

docker pull ros:jazzy
mkdir -p /root/work
docker run -d --name ros2 -v /root/work:/work -w /work ros:jazzy sleep infinity
docker exec ros2 bash -c "apt-get update -qq && apt-get install -y -qq ros-jazzy-ros-gz-sim ros-jazzy-ros-gz-bridge"
docker exec ros2 bash -c "echo 'source /opt/ros/jazzy/setup.bash' >> /root/.bashrc"

touch /tmp/ros2-ready
