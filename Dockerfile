# 베이스 이미지 설정 (CUDA 11.7 및 cuDNN 8.2 지원)
FROM nvidia/cuda:11.7.1-cudnn8-devel-ubuntu20.04

ARG DEBIAN_FRONTEND=noninteractive

# 필수 의존성 설치 (libxml2 포함)
RUN apt-get update && apt-get install -y \
    wget \
    libxml2 \
    build-essential \
    cmake \
    curl \
    git \
    libgl1-mesa-glx \
    libglib2.0-0 \
    ninja-build \
    python3-dev \
    python3-pip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Miniconda 설치
WORKDIR /tmp
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && bash Miniconda3-latest-Linux-x86_64.sh -b -p /opt/conda \
    && rm Miniconda3-latest-Linux-x86_64.sh

# Conda 환경변수 설정
ENV PATH=/opt/conda/bin:$PATH

# Conda 최신 업데이트
RUN conda update -n base -c defaults conda

# Conda 가상환경 및 필수 패키지 설치
RUN conda create -n cf3dgs python=3.10 -y \
    && /bin/bash -c "source activate cf3dgs && conda install conda-forge::cudatoolkit-dev=11.7.0 -y" \
    && /bin/bash -c "source activate cf3dgs && conda install pytorch==2.0.0 torchvision==0.15.0 pytorch-cuda=11.7 -c pytorch -c nvidia -y"

# 작업 디렉토리 설정
WORKDIR /workspace

# Git에서 소스코드 복제 (recursive로 하위 모듈까지 클론)
RUN git clone https://github.com/NVlabs/CF-3DGS.git /workspace/CF-3DGS \
    && cd /workspace/CF-3DGS \
    && git submodule update --init --recursive

# Conda 환경 활성화 후 의존성 설치
RUN /bin/bash -c "source activate cf3dgs && cd /workspace/CF-3DGS && pip install -r requirements.txt"

# 기본 작업 디렉토리 설정
WORKDIR /workspace/CF-3DGS

# 컨테이너 시작 시 Conda 환경을 활성화
CMD ["/bin/bash", "-c", "source activate cf3dgs && /bin/bash"]
