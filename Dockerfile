# This is an auto generated Dockerfile for ros:desktop-full
# generated from docker_images/create_ros_image.Dockerfile.em
FROM osrf/ros:kinetic-desktop-xenial

# install ros packages
RUN apt-get update && apt-get install -y \
    ros-kinetic-desktop-full=1.3.1-0* \
    && rm -rf /var/lib/apt/lists/*

# Enable Ubuntu Universe, Multiverse, and deb-src for main.
RUN apt-get install -y software-properties-common
RUN add-apt-repository "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) main universe restricted multiverse"
RUN apt-get update


RUN apt-get install -y \
    python-catkin-pkg \
    python-rosdep \
    python-wstool \
    ros-kinetic-catkin \
    libttspico-utils \
    mpg123 \
    libgnutls28-dev

RUN source /opt/ros/kinetic/setup.bash

RUN pip install gtts 
RUN rosdep init
RUN rosdep update


# Create a catkin workspace with the package under integration.

RUN mkdir -p ~/sara_ws/src
WORKDIR ~/sara_ws/src
RUN catkin_init_workspace
WORKDIR ~/sara_ws
RUN catkin_make
RUN source devel/setup.bash


# Install all dependencies, using wstool first and rosdep second.

WORKDIR ~/sara_ws/src
RUN wstool init
RUN wget https://raw.githubusercontent.com/WalkingMachine/wm_ci_build/feature/test_docker/sara.rosinstall
RUN wstool merge sara.rosinstall
RUN wstool up

WORKDIR ~/sara_ws
RUN rosdep install -y --from-paths src --ignore-src --rosdistro kinetic


# compile and test

RUN source /opt/ros/kinetic/setup.bash
WORKDIR ~/sara_ws
RUN catkin_make
RUN source devel/setup.bash
RUN catkin_make run_tests && catkin_test_results
