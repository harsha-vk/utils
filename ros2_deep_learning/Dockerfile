ARG BASE_IMAGE=nvidia/cuda:12.1.1-cudnn8-runtime-ubuntu20.04
FROM ${BASE_IMAGE}
ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-c"]
WORKDIR /tmp

# Install opencv
ARG OPENCV_URL='xxxx' \
    OPENCV_FILE=OpenCV-4.7.0-x86_64.tar.gz
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
    ln -s /usr/include/opencv4 /usr/local/include/opencv4 && \
    ln -s /usr/lib/python3.8/site-packages/cv2 /usr/local/lib/python3.8/dist-packages/cv2 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
RUN rm -rf opencv
RUN python3 -c "import cv2; print('OpenCV version:', str(cv2.__version__)); print(cv2.getBuildInformation())"

# Build ros2 humble
ARG ROS_PKG=desktop
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
        python3-rosinstall-generator \
        ros-dev-tools \
        python2- && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean
RUN pip3 install --upgrade --no-cache-dir \
        flake8-blind-except \
        flake8-builtins \
        flake8-class-newline \
        flake8-comprehensions \
        flake8-deprecated \
        flake8-import-order \
        flake8-quotes \
        "pytest>=5.3" \
        pytest-repeat \
        pytest-rerunfailures

RUN mkdir -p ${ROS_ROOT}/src && \
    cd ${ROS_ROOT} && \
    rosinstall_generator --deps --rosdistro ${ROS_DISTRO} ${ROS_PKG} \
        > ros2.${ROS_DISTRO}.rosinstall && \
    while ! vcs import src < ros2.${ROS_DISTRO}.rosinstall; do :; done && \
    rm ${ROS_ROOT}/*.rosinstall

RUN apt-get update && \
    cd ${ROS_ROOT} && \
    rosdep init && \
    rosdep update && \
    rosdep install -y -q \
        --ignore-src \
        --from-paths src \
        --skip-keys "libopencv-dev libopencv-contrib-dev libopencv-imgproc-dev python-opencv python3-opencv fastcdr rti-connext-dds-6.0.1 urdfdom_headers" && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

RUN cd ${ROS_ROOT} && \
    colcon build --merge-install --cmake-args -DCMAKE_BUILD_TYPE=Release

RUN rm -rf ${ROS_ROOT}/src && \
    rm -rf ${ROS_ROOT}/logs && \
    rm -rf ${ROS_ROOT}/build

ENV RMW_IMPLEMENTATION=rmw_cyclonedds_cpp

# Install tensorrt
ARG TENSORRT_URL='https://developer.nvidia.com/downloads/compute/machine-learning/tensorrt/secure/8.6.1/tars/TensorRT-8.6.1.6.Linux.x86_64-gnu.cuda-12.0.tar.gz' \
    TENSORRT_FILE=TensorRT-8.6.1.6.Linux.x86_64-gnu.cuda-12.0.tar.gz
RUN wget --quiet --show-progress --progress=bar:force:noscroll ${TENSORRT_URL} -O ${TENSORRT_FILE} && \
    tar -xzvf ${TENSORRT_FILE} -C -C /usr/src && \
    mv /usr/src/TensorRT-* /usr/src/tensorrt && \
    cp -r /usr/src/tensorrt/lib/* /usr/lib/x86_64-linux-gnu/ && \
    cp -r /usr/src/tensorrt/include/* /usr/include/x86_64-linux-gnu/ && \
    pip3 install --no-cache-dir /usr/src/tensorrt/python/tensorrt-*-cp38-*.whl && \
    rm ${TENSORRT_FILE}

# Install tensorflow
RUN pip3 install --no-cache-dir tensorflow[and-cuda]==1.15.5
RUN python3 -c "import tensorflow as tf; print(tf.config.list_physical_devices('GPU'))"

# Install pytorch
RUN pip3 install --no-cache-dir torch==2.1.0 torchvision==0.16.0 torchaudio==2.1.0 --index-url https://download.pytorch.org/whl/cu121
RUN python3 -c 'import torch; print(f"PyTorch version: {torch.__version__}"); print(f"CUDA available: {torch.cuda.is_available()}"); print(f"cuDNN version: {torch.backends.cudnn.version()}"); print(torch.__config__.show());'

# Entrypoint
COPY ./ros_entrypoint.sh /ros_entrypoint.sh
ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]
WORKDIR /
