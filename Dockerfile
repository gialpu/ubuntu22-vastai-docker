# Ubuntu 22.04 Docker Image for Vast.ai
# Using lighter NVIDIA CUDA base image

FROM nvidia/cuda:12.1.1-cudnn8-devel-ubuntu22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV WORKSPACE=/workspace
ENV PYTHON_VERSION=3.10

# Update system and install essential packages
RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    vim \
    nano \
    htop \
    tmux \
    screen \
    build-essential \
    cmake \
    pkg-config \
    python${PYTHON_VERSION} \
    python${PYTHON_VERSION}-venv \
    python3-pip \
    openssh-server \
    supervisor \
    nginx \
    zip \
    unzip \
    tree \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create Python virtual environment
RUN python${PYTHON_VERSION} -m venv /venv/main

# Activate virtual environment and install Python packages
RUN . /venv/main/bin/activate && \
    pip install --no-cache-dir --upgrade pip setuptools wheel && \
    pip install --no-cache-dir \
    torch \
    torchvision \
    torchaudio \
    numpy \
    pandas \
    scipy \
    scikit-learn \
    matplotlib \
    pillow \
    opencv-python-headless \
    transformers \
    accelerate \
    diffusers \
    safetensors \
    huggingface-hub \
    jupyter \
    jupyterlab \
    ipython \
    gradio \
    fastapi \
    uvicorn \
    requests \
    tqdm \
    pyyaml

# Setup SSH
RUN mkdir /var/run/sshd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Create workspace directory
RUN mkdir -p /workspace && chmod 777 /workspace

# Setup Jupyter
RUN . /venv/main/bin/activate && \
    jupyter notebook --generate-config && \
    echo "c.NotebookApp.ip = '0.0.0.0'" >> ~/.jupyter/jupyter_notebook_config.py && \
    echo "c.NotebookApp.allow_root = True" >> ~/.jupyter/jupyter_notebook_config.py && \
    echo "c.NotebookApp.open_browser = False" >> ~/.jupyter/jupyter_notebook_config.py

# Create startup script
RUN echo '#!/bin/bash\n\
echo "========================================"\n\
echo "Ubuntu 22.04 + CUDA 12.1.1 + PyTorch"\n\
echo "========================================"\n\
echo ""\n\
echo "Python: $(python --version)"\n\
if command -v nvcc &> /dev/null; then\n\
    echo "CUDA: $(nvcc --version | grep release)"\n\
fi\n\
if python -c "import torch" 2>/dev/null; then\n\
    echo "PyTorch: $(python -c "import torch; print(torch.__version__)")"\n\
    echo "CUDA Available: $(python -c "import torch; print(torch.cuda.is_available())")"\n\
fi\n\
if command -v nvidia-smi &> /dev/null; then\n\
    echo ""\n\
    nvidia-smi\n\
fi\n\
echo ""\n\
echo "Virtual env: /venv/main"\n\
echo "Workspace: /workspace"\n\
echo ""\n\
echo "To start Jupyter: jupyter lab --ip=0.0.0.0 --port=8888 --allow-root"\n\
echo "To start SSH: service ssh start"\n\
echo ""' > /usr/local/bin/welcome.sh && \
    chmod +x /usr/local/bin/welcome.sh

# Add welcome message to bashrc
RUN echo '. /venv/main/bin/activate' >> /root/.bashrc && \
    echo '/usr/local/bin/welcome.sh' >> /root/.bashrc

# Set working directory
WORKDIR /workspace

# Expose ports
EXPOSE 8888 22 6006 7860

# Default command
CMD ["/bin/bash"]
