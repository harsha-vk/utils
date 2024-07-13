#!/bin/bash
set -e

# ros_env_setup="$ROS_ROOT/install/setup.bash"
ros_env_setup="$ROS_ROOT/ros2-linux/setup.bash"
echo "sourcing   $ros_env_setup"
source "$ros_env_setup"

echo "ROS_ROOT   $ROS_ROOT"
echo "ROS_DISTRO $ROS_DISTRO"

exec "$@"
