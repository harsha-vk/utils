# ROS2 Deep Learning - Docker Container

## Resources

- https://docs.nvidia.com/cuda/wsl-user-guide/index.html
- https://docs.nvidia.com/deeplearning/cudnn/archives/cudnn-890/index.html
- https://docs.nvidia.com/deeplearning/tensorrt/archives/tensorrt-1001/install-guide/index.html
- https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html
- https://catalog.ngc.nvidia.com/orgs/nvidia/containers/cuda
- https://gitlab.com/nvidia/container-images/cuda/-/tree/master/dist?ref_type=heads
- https://docs.ros.org/en/humble/Installation/Alternatives/Ubuntu-Development-Setup.html
- https://docs.nvidia.com/deeplearning/frameworks/pytorch-release-notes/rel-23-04.html#rel-23-04
- https://docs.nvidia.com/deeplearning/frameworks/tensorflow-release-notes/rel-23-04.html#rel-23-04
- https://www.tensorflow.org/install
- https://pytorch.org/get-started/previous-versions/
- https://onnxruntime.ai/docs/execution-providers/

export PATH=/usr/local/cuda-12.1/bin:$PATH
sudo nano /etc/ld.so.conf
/usr/local/cuda-12.1/lib64
sudo ldconfig
