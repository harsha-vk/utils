## Jupyter Lab Setup

### Step 1 - Install dependencies

1. Install Node JS to support Jupyter Lab

    ```bash
    curl -fsSL https://deb.nodesource.com/setup_16.x | sudo bash -
    sudo apt-get install -y nodejs libffi-dev
    ```

2. Set up a virtual environment to install Jupyter Lab.

    ```bash
    cd remote_venv
    python3 -m venv jupyter

    source jupyter/bin/activate
    ```

4. Install Jupyter Lab to support web-programming

    ```bash
    pip install --upgrade --no-cache-dir pip
    pip install --no-cache-dir jupyter jupyterlab
    jupyter labextension install @jupyter-widgets/jupyterlab-manager
    ```

5. (Optional) Install Jupyter Clickable Image widget.

    ```bash
    sudo apt-get install -y libssl1.0-dev && \
    git clone https://github.com/jaybdub/jupyter_clickable_image_widget && \
    cd jupyter_clickable_image_widget && \
    git checkout tags/v0.1 && \
    sudo pip3 install -e . && \
    jupyter labextension install js && \
    jupyter lab build
    cd ..
    ```

### Step 2 - Set the Jupyter lab password

Call the following from a terminal
```bash
jupyter notebook password
# enter password
```

You could now test the notebooks by running

```bash
jupyter lab --ip=0.0.0.0 --no-browser --allow-root
```

and then navigating to ``https://<jetson_ip>:8888`` and signing in with the password you set.

However, it is convenient to have this server start automatically, which we will detail next.

### Step 3 - Create a system service to start the Jupyter Lab server at boot

1. Create file named ``jetson_jupyter.service`` and add the following content.

    ```bash
    [Unit]
    Description=Jupyter Notebook

    [Service]
    Type=simple
    User=jetson
    ExecStart=/bin/sh -c ". /home/jetson/remote_venv/jupyter/bin/activate && jupyter lab --ip=0.0.0.0 --no-browser --allow-root"
    WorkingDirectory=/home/jetson
    Restart=Always

    [Install]
    WantedBy=multi-user.target
    ```

    > Note: If you have a username other than "jetson" or want to launch Jupyter from a directory other than "/home/jetson", modify the file "User" and "WorkingDirectory" fields accordingly.

2. Copy the file to the directory ``/etc/systemd/system`` so it can be discovered as a system service.

    ```bash
    sudo cp jetson_jupyter.service /etc/systemd/system/jetson_jupyter.service
    ```

3. Enable the system service to run at boot

    ```bash
    sudo systemctl enable jetson_jupyter
    ```

Now, when you re-boot your Jetson, the Jupyter lab server should start in the background.

## Jetson Nano Configurations

### Disable GUI

```bash
# Disable GUI to free up more RAM
sudo systemctl set-default multi-user
```

### Free System Swap

```bash
# Disable ZRAM
sudo systemctl disable nvzramconfig.service
```

### Re-Enable GUI

```bash
# Re-enable GUI
sudo systemctl set-default graphical.target
```

### Configure Swap file

Copy `enable_swap.sh` file to pwd and run the following command.

```bash
sudo sh enable_swap.sh
```

## Additional Resources

- [Running and Building ARM Docker Containers on x86](https://www.stereolabs.com/docs/docker/building-arm-container-on-x86)
