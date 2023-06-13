FROM anibali/pytorch:1.8.1-cuda11.1
USER root

WORKDIR /workspace
ENV CUDA_HOME=/usr/local/cuda
ENV TZ=Europe/London
ENV HOME=/config
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt update -q \
  && apt install -y -qq tzdata bash build-essential git curl wget software-properties-common \
    vim ca-certificates libffi-dev libssl-dev libsndfile1 libbz2-dev liblzma-dev locales \
    libboost-all-dev libboost-tools-dev libboost-thread-dev cmake libpq-dev \
    python3 python3-setuptools python3-pip cython

RUN apt install -y portaudio19-dev
# Install package dependencies
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        alsa-base \
        alsa-utils \
        libsndfile1-dev && \
    apt-get clean

RUN git clone https://github.com/kpu/kenlm.git /usr/local/src/kenlm 
WORKDIR /usr/local/src/kenlm 
RUN mkdir -p build && cd build && cmake .. && make -j 4

ENV PATH="/usr/local/src/kenlm/build/bin:/usr/local/src/kenlm/scripts:${PATH}"

RUN pip install --upgrade pip
COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt --no-cache-dir

WORKDIR /workspace