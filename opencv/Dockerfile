ARG BASE_IMAGE=nvidia/cuda:12.1.1-cudnn8-devel-ubuntu22.04
FROM ${BASE_IMAGE}
ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-c"]
WORKDIR /tmp

# Install build dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        gfortran \
        cmake \
        git \
        file \
        tar \
        libatlas-base-dev \
        libavcodec-dev \
        libavformat-dev \
        libcanberra-gtk3-module \
        libeigen3-dev \
        libglew-dev \
        libgstreamer-plugins-base1.0-dev \
        libgstreamer-plugins-good1.0-dev \
        libgstreamer1.0-dev \
        libgtk-3-dev \
        libjpeg-dev \
        libjpeg8-dev \
        libjpeg-turbo8-dev \
        liblapack-dev \
        liblapacke-dev \
        libopenblas-dev \
        libpng-dev \
        libpostproc-dev \
        libswscale-dev \
        libtbb-dev \
        libtbb2 \
        libtesseract-dev \
        libtiff-dev \
        libv4l-dev \
        libxine2-dev \
        libxvidcore-dev \
        libx264-dev \
        libgtkglext1 \
        libgtkglext1-dev \
        pkg-config \
        qv4l2 \
        v4l-utils \
        zlib1g-dev \
        python3-pip \
        python3-dev \
        python3-numpy \
        python3-distutils \
        python3-setuptools && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

# Get source code
ARG OPENCV_PYTHON=4.x \
    OPENCV_VERSION=4.7.0 \
    OPENCV_ROOT=/tmp/opencv-python
RUN git clone --branch ${OPENCV_PYTHON} --recursive https://github.com/opencv/opencv-python ${OPENCV_ROOT}
RUN cd ${OPENCV_ROOT}/opencv && \
    git checkout --recurse-submodules ${OPENCV_VERSION} && \
    cd ${OPENCV_ROOT}/opencv_contrib && \
    git checkout --recurse-submodules ${OPENCV_VERSION} && \
    cd ${OPENCV_ROOT}/opencv_extra && \
    git checkout --recurse-submodules ${OPENCV_VERSION}

# Apply patches
RUN ln -s /usr/include/x86_64-linux-gnu/cudnn_version_v*.h /usr/include/x86_64-linux-gnu/cudnn_version.h && \
    sed -i 's|weight != 1.0|(float)weight != 1.0f|' ${OPENCV_ROOT}/opencv/modules/dnn/src/cuda4dnn/primitives/normalize_bbox.hpp && \
    sed -i 's|nms_iou_threshold > 0|(float)nms_iou_threshold > 0.0f|' ${OPENCV_ROOT}/opencv/modules/dnn/src/cuda4dnn/primitives/region.hpp

# Build
ARG CUDA_ARCH_BIN=7.5 \
    CMAKE_FLAGS="\
        -DCPACK_BINARY_DEB=ON \
        -DBUILD_EXAMPLES=OFF \
        -DBUILD_opencv_python2=OFF \
        -DBUILD_opencv_python3=ON \
        -DBUILD_opencv_java=OFF \
        -DCMAKE_BUILD_TYPE=RELEASE \
        -DCMAKE_INSTALL_PREFIX=/usr/local \
        -DCUDA_ARCH_BIN=${CUDA_ARCH_BIN} \
        -DCUDA_ARCH_PTX= \
        -DCUDA_FAST_MATH=ON \
        -DCUDNN_INCLUDE_DIR=/usr/include/x86_64-linux-gnu \
        -DEIGEN_INCLUDE_PATH=/usr/include/eigen3 \
        -DWITH_EIGEN=ON \
        -DENABLE_NEON=OFF \
        -DOPENCV_DNN_CUDA=ON \
        -DOPENCV_ENABLE_NONFREE=ON \
        -DOPENCV_EXTRA_MODULES_PATH=${OPENCV_ROOT}/opencv_contrib/modules \
        -DOPENCV_GENERATE_PKGCONFIG=ON \
        -DOpenGL_GL_PREFERENCE=GLVND \
        -DWITH_CUBLAS=ON \
        -DWITH_CUDA=ON \
        -DWITH_CUDNN=ON \
        -DWITH_GSTREAMER=ON \
        -DWITH_LIBV4L=ON \
        -DWITH_GTK=ON \
        -DWITH_OPENGL=OFF \
        -DWITH_OPENCL=OFF \
        -DWITH_IPP=OFF \
        -DWITH_TBB=ON \
        -DBUILD_TIFF=ON \
        -DBUILD_PERF_TESTS=OFF \
        -DBUILD_TESTS=OFF"
ENV ENABLE_CONTRIB=1
RUN mkdir -p ${OPENCV_ROOT}/build && \
    cd ${OPENCV_ROOT}/build && \
    cmake ${CMAKE_FLAGS} ${OPENCV_ROOT}/opencv && \
    make -j$(nproc)
RUN cd ${OPENCV_ROOT}/build && \
    make install && \
    make package && \
    make uninstall && \
    dpkg -i *.deb
RUN cd ${OPENCV_ROOT}/build && \
    tar -czvf OpenCV-${OPENCV_VERSION}-x86_64.tar.gz *.deb && \
    mv OpenCV-${OPENCV_VERSION}-x86_64.tar.gz /tmp

# Clean
RUN rm -rf ${OPENCV_ROOT}  

# Verify
ENV PYTHONPATH=${PYTHONPATH}:/usr/lib/python3.8/site-packages
RUN python3 -c "import cv2; print('OpenCV version:', str(cv2.__version__)); print(cv2.getBuildInformation())"

CMD ["bash"]
WORKDIR /
