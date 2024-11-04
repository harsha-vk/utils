ARG BASE_IMAGE=nvidia/cuda:12.1.1-devel-ubuntu22.04
FROM ${BASE_IMAGE}
ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-c"]
WORKDIR /tmp

# ## Install opencv
# ARG OPENCV_URL='https://www.dropbox.com/scl/fi/w4pi35bi6f1npq84y9bks/OpenCV-4.7.0-ubuntu22.04cuda12.1.1cudnn8.9.0-x86_64.tar.gz?rlkey=gh1va636nyh1yk84bu6ae69j7&st=lys6sy76&dl=1' \
#     OPENCV_FILE=OpenCV-4.7.0-ubuntu22.04cuda12.1.1cudnn8.9.0-x86_64.tar.gz
# RUN apt-get purge -y '.*opencv.*' || echo "previous OpenCV installation not found" && \
#     apt-get update && \
#     apt-get install -y --no-install-recommends \
#         wget \
#         python3-numpy && \
#     rm -rf /var/lib/apt/lists/* && \
#     apt-get clean
# RUN mkdir opencv && \
#     cd opencv && \
#     wget --quiet --show-progress --progress=bar:force:noscroll ${OPENCV_URL} -O ${OPENCV_FILE} && \
#     tar -xzvf ${OPENCV_FILE} && \
#     dpkg -i --force-depends *.deb && \
#     apt-get update && \
#     apt-get install -y -f --no-install-recommends && \
#     dpkg -i *.deb && \
#     apt-get clean && \
#     rm -rf /var/lib/apt/lists/*
# RUN rm -rf opencv
# RUN python3 -c "import cv2; print('OpenCV version:', str(cv2.__version__)); print(cv2.getBuildInformation())"

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

RUN apt-get install -y --no-install-recommends ros-humble-desktop-full ros-dev-tools python2-

# ARG ROS_URL='https://github.com/ros2/ros2/releases/download/release-humble-20240523/ros2-humble-20240523-linux-jammy-amd64.tar.bz2' \
#     ROS_FILE=ros2-humble-20240523-linux-jammy-amd64.tar.bz2
# RUN mkdir -p ${ROS_ROOT} && \
#     cd ${ROS_ROOT} && \
#     wget --quiet --show-progress --progress=bar:force:noscroll ${ROS_URL} -O ${ROS_FILE} && \
#     tar -xf ${ROS_FILE} && \
#     rm ${ROS_FILE}
# RUN apt-get update && \
#     apt-get upgrade && \
#     apt-get install -y -no-install-recommends \
#         python3-rosdep \
#         ros-dev-tools
#         python2- && \
#     rosdep init && \
#     rosdep update && \
#     rosdep install -y -q \
#         --ignore-src \
#         --from-paths ${ROS_ROOT}/ros2-linux/share \
#         --skip-keys "cyclonedds fastcdr fastrtps rti-connext-dds-6.0.1 urdfdom_headers" && \
#     rm -rf /var/lib/apt/lists/* && \
#     apt-get clean

# ## Build ros2 humble
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

RUN echo 'source ${ROS_ROOT}/setup.bash' >> /root/.bashrc

## Install tensorrt and pytorch
RUN python3 -m pip install --no-cache-dir \
                            'numpy<2.0.0' \
                            torch==2.3.1 \
                            torchvision==0.18.1 \
                            torch-tensorrt==2.3.0 \
                            tensorrt==10.0.1 \
                            tensorrt-cu12==10.0.1 \
                            --extra-index-url https://download.pytorch.org/whl/cu121
RUN python3 -c "import tensorrt; print('TensorRT version:', str(tensorrt.__version__))"
RUN python3 -c 'import torch; print(f"PyTorch version: {torch.__version__}"); print(f"CUDA available: {torch.cuda.is_available()}"); print(f"cuDNN version: {torch.backends.cudnn.version()}"); print(torch.__config__.show());'

## Install onnxruntime (cuda 12.x, cudnn 8.x)
RUN python3 -m pip install --no-cache-dir \
                            onnxruntime-gpu==1.18.0 \
                            --extra-index-url https://aiinfra.pkgs.visualstudio.com/PublicPackages/_packaging/onnxruntime-cuda-12/pypi/simple/

# ## Install tensorflow
# RUN pip3 install --no-cache-dir tensorflow[and-cuda]
# RUN python3 -c "import tensorflow as tf; print(tf.config.list_physical_devices('GPU'))"

CMD ["bash"]
WORKDIR /workspace
