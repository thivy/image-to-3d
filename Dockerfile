# Use the official CUDA image with Ubuntu 22.04 as the base image
FROM nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu22.04

# Set the working directory
WORKDIR /app

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install Conda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    /opt/conda/bin/conda clean --all --yes && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc

# Add Conda to PATH
ENV PATH=/opt/conda/bin:$PATH

# Clone the repository and submodules
RUN git clone --recurse-submodules https://github.com/microsoft/TRELLIS.git /app

# Set up the Conda environment and install dependencies
RUN . /opt/conda/etc/profile.d/conda.sh && \
    cd /app && \
    ./setup.sh --new-env --basic --xformers --flash-attn --diffoctreerast --spconv --mipgaussian --kaolin --nvdiffrast

# Install FastAPI and Uvicorn
RUN pip install fastapi uvicorn

# Copy the API script
COPY app.py /app/app.py

# Set the entrypoint
ENTRYPOINT ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]

# Expose the port
EXPOSE 8000