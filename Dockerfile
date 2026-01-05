# Ubuntu 22.04 Docker Image for Vast.ai
# Based on official Vast.ai base image with CUDA support

FROM vastai/base-image:cuda-12.1.1-auto
# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV WORKSPACE=/workspace
ENV PATH=/venv/main/bin:$PATH

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
    ninja-build \
    pkg-config \
    libssl-dev \
    libffi-dev \
    python3-dev \
    python3-pip \
    software-properties-common \
    ca-certificates \
    gnupg \
    lsb-release \
    zip \
    unzip \
    tree \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Activate virtual environment and upgrade pip
RUN . /venv/main/bin/activate && \
    pip install --no-cache-dir --upgrade pip setuptools wheel

# Install common Python packages for AI/ML
RUN . /venv/main/bin/activate && \
    pip install --no-cache-dir \
    torch \
    torchvision \
    torchaudio \
    numpy \
    pandas \
    scipy \
    scikit-learn \
    matplotlib \
    seaborn \
    plotly \
    opencv-python \
    pillow \
    transformers \
    accelerate \
    diffusers \
    xformers \
    bitsandbytes \
    safetensors \
    huggingface-hub \
    datasets \
    tokenizers \
    jupyter \
    jupyterlab \
    ipython \
    notebook \
    gradio \
    streamlit \
    fastapi \
    uvicorn \
    pydantic \
    requests \
    aiohttp \
    tensorboard \
    wandb \
    mlflow \
    tqdm \
    pyyaml \
    python-dotenv

# Create workspace directory with proper permissions
RUN mkdir -p /workspace && chmod 777 /workspace

# Set working directory
WORKDIR /workspace

# Create a welcome script
RUN echo '#!/bin/bash\n\
echo "======================================"\n\
echo "Ubuntu 22.04 + CUDA 12.1.1 + PyTorch"\n\
echo "======================================"\n\
echo ""\n\
echo "Python: $(python --version)"\n\
echo "CUDA: $(nvcc --version | grep release)"\n\
echo "PyTorch: $(python -c "import torch; print(torch.__version__)")"\n\
echo "CUDA Available: $(python -c "import torch; print(torch.cuda.is_available())")"\n\
if command -v nvidia-smi &> /dev/null; then\n\
    echo ""\n\
    nvidia-smi\n\
fi\n\
echo ""\n\
echo "Virtual env: /venv/main (already activated)"\n\
echo "Workspace: /workspace"\n\
echo ""\n\
echo "Services:"\n\
echo "- Jupyter: Port 8888"\n\
echo "- SSH: Port 22"\n\
echo "- Instance Portal: Port 3022"\n\
echo ""' > /usr/local/bin/welcome.sh && \
    chmod +x /usr/local/bin/welcome.sh

# Add welcome message to bashrc
RUN echo '. /venv/main/bin/activate' >> /root/.bashrc && \
    echo '/usr/local/bin/welcome.sh' >> /root/.bashrc

# Expose common ports
EXPOSE 8888 6006 7860 8080 22 3022

# The entrypoint is inherited from vastai/base-image
# It handles SSH, Jupyter, and Instance Portal automatically
