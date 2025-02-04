# Use NVIDIA CUDA runtime as the base image for GPU support
FROM nvidia/cuda:11.7.1-cudnn8-runtime-ubuntu20.04

ENV DEBIAN_FRONTEND=noninteractive

# Install Python 3.8, pip, and system dependencies
RUN apt-get update && apt-get install -y \
    python3.8 \
    python3-pip \
    build-essential \
    libjpeg-dev \
    libpng-dev \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip and install required Python packages
RUN pip3 install --upgrade pip && \
    pip3 install fastapi uvicorn pillow trellis

# Set the working directory
WORKDIR /app

COPY app.py /app/app.py
# Copy the entire project
COPY . /app

# Expose the API port
EXPOSE 8000

# Start the FastAPI application using Uvicorn
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]