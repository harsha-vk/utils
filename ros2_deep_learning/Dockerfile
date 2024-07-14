ARG BASE_IMAGE=nvidia/cuda:12.1.1-cudnn8-runtime-ubuntu22.04
FROM ${BASE_IMAGE}
ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-c"]
WORKDIR /tmp

## Install opencv
ARG OPENCV_URL='https://www.dropbox.com/scl/fi/w4pi35bi6f1npq84y9bks/OpenCV-4.7.0-ubuntu22.04cuda12.1.1cudnn8.9.0-x86_64.tar.gz?rlkey=gh1va636nyh1yk84bu6ae69j7&st=lys6sy76&dl=1' \
    OPENCV_FILE=OpenCV-4.7.0-ubuntu22.04cuda12.1.1cudnn8.9.0-x86_64.tar.gz
RUN apt-get purge -y '.*opencv.*' || echo "previous OpenCV installation not found" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        wget \
        python3-numpy && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean
RUN mkdir opencv && \
    cd opencv && \
    wget --quiet --show-progress --progress=bar:force:noscroll ${OPENCV_URL} -O ${OPENCV_FILE} && \
    tar -xzvf ${OPENCV_FILE} && \
    dpkg -i --force-depends *.deb && \
    apt-get update && \
    apt-get install -y -f --no-install-recommends && \
    dpkg -i *.deb && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
RUN rm -rf opencv
# ENV PYTHONPATH=${PYTHONPATH}:/usr/lib/python3.8/site-packages
RUN python3 -c "import cv2; print('OpenCV version:', str(cv2.__version__)); print(cv2.getBuildInformation())"

## Install ros2 humble
ENV ROS_DISTRO=humble \
    ROS_ROOT=/opt/ros/${ROS_DISTRO}

RUN apt-get update && \
    apt-get install -y --no-install-recommends locales && \
    locale-gen en_US en_US.UTF-8 && \
    update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean
ENV LANG=en_US.UTF-8

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        software-properties-common \
        curl \
        git \
        nano \
        wget && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        python3-flake8-docstrings \
        python3-pip \
        python3-pytest-cov \
        ros-dev-tools \
        python3-rosinstall-generator \
        python2- \
        python3-flake8-blind-except \
        python3-flake8-builtins \
        python3-flake8-class-newline \
        python3-flake8-comprehensions \
        python3-flake8-deprecated \
        python3-flake8-import-order \
        python3-flake8-quotes \
        python3-pytest-repeat \
        python3-pytest-rerunfailures && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

ARG ROS_URL='https://github.com/ros2/ros2/releases/download/release-humble-20240523/ros2-humble-20240523-linux-jammy-amd64.tar.bz2' \
    ROS_FILE=ros2-humble-20240523-linux-jammy-amd64.tar.bz2
RUN mkdir -p ${ROS_ROOT} && \
    cd ${ROS_ROOT} && \
    wget --quiet --show-progress --progress=bar:force:noscroll ${ROS_URL} -O ${ROS_FILE} && \
    tar -xf ${ROS_FILE} && \
    rm ${ROS_FILE}

RUN apt-get update && \
    rosdep init && \
    rosdep update && \
    rosdep install -y -q \
        --ignore-src \
        --from-paths ${ROS_ROOT}/ros2-linux/share \
        --skip-keys "libopencv-dev libopencv-contrib-dev libopencv-imgproc-dev python-opencv python3-opencv fastcdr rti-connext-dds-6.0.1 urdfdom_headers" && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

# # https://github.com/gazebosim/gz-rendering/issues/662
# ENV LIBGL_ALWAYS_SOFTWARE=1

### Build ros2 humble
# RUN mkdir -p ${ROS_ROOT}/src && \
#     cd ${ROS_ROOT} && \
#     rosinstall_generator --deps --rosdistro ${ROS_DISTRO} desktop perception navigation2 \
#         > ros2.${ROS_DISTRO}.rosinstall && \
#     while ! vcs import src < ros2.${ROS_DISTRO}.rosinstall; do :; done && \
#     rm ${ROS_ROOT}/*.rosinstall

# RUN cd ${ROS_ROOT} && \
#     colcon build --merge-install --cmake-args -DCMAKE_BUILD_TYPE=Release

# RUN rm -rf ${ROS_ROOT}/src && \
#     rm -rf ${ROS_ROOT}/logs && \
#     rm -rf ${ROS_ROOT}/build

# ENV RMW_IMPLEMENTATION=rmw_cyclonedds_cpp

## Entrypoint
COPY ./ros_entrypoint.sh /ros_entrypoint.sh
ENTRYPOINT ["/ros_entrypoint.sh"]

## Install tensorrt
ARG TENSORRT_URL='https://developer.nvidia.com/downloads/compute/machine-learning/tensorrt/10.0.1/local_repo/nv-tensorrt-local-repo-ubuntu2204-10.0.1-cuda-12.4_1.0-1_amd64.deb' \
    TENSORRT_FILE=nv-tensorrt-local-repo-ubuntu2204-10.0.1-cuda-12.4_1.0-1_amd64.deb
RUN wget --quiet --show-progress --progress=bar:force:noscroll ${TENSORRT_URL} -O ${TENSORRT_FILE} && \
    dpkg -i ${TENSORRT_FILE} && \
    sudo cp /var/nv-tensorrt-local-repo-*/*-keyring.gpg /usr/share/keyrings/ && \
    apt-get update && \
    apt-get install -y --no-install-recommends tensorrt && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean && \
    apt-get purge -y nv-tensorrt-local-repo-* && \
    rm ${TENSORRT_FILE}

## Install tensorflow
RUN pip3 install --no-cache-dir tensorflow[and-cuda]==2.12.0
RUN python3 -c "import tensorflow as tf; print(tf.config.list_physical_devices('GPU'))"

## Install pytorch
RUN pip install torch==2.1.0 torchvision==0.16.0 torchaudio==2.1.0 --index-url https://download.pytorch.org/whl/cu121
RUN python3 -c 'import torch; print(f"PyTorch version: {torch.__version__}"); print(f"CUDA available: {torch.cuda.is_available()}"); print(f"cuDNN version: {torch.backends.cudnn.version()}"); print(torch.__config__.show());'

CMD ["bash"]
WORKDIR /
