# OpenCV with CUDA and cuDNN

## Build Binary packages using Docker images

- ARGs
    ```
    BASE_IMAGE = nvcr.io/nvidia/cuda:12.1.1-cudnn8-devel-ubuntu22.04
    OPENCV_VERSION = 4.7.0
    CUDA_ARCH_BIN = 7.5 for NVIDIA GTX 1650 (Notebook)
    ```
- Build image using Dockerfile.

    ```bash
    cd path/to/Dockerfile
    docker build -t opencv_cuda .
    ```
    `Note: 'docker build' command might be deprecated in the future docker releases.`
- Run docker image and get container id.
    ```bash
    docker run --rm -it --gpus all opencv_cuda
    ```
- Run below command in new terminal to export binary file.
    ```
    docker cp <container id>:/<opencv tar file> <destination path>
    ```

## Resources

- OpenCV versions below 4.7 are not supported by CUDA 12 - https://stackoverflow.com/a/74836282
- https://github.com/mdegans/nano_build_opencv/tree/master
- https://github.com/dusty-nv/jetson-containers/tree/master/packages/opencv
- https://gist.github.com/dlime/63759eda46044be94c116435e2d999a5
