FROM ubuntu:16.04

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -qq && \
    apt-get install -qq apt-utils dialog

# Python 3.7
RUN apt-get install -qq software-properties-common && \
    add-apt-repository -y ppa:deadsnakes/ppa && \
    apt-get update -qq && \
    apt-get install -qq python3.7 python3.7-dev python3-pip && \
    cp $(which python3.7) /usr/bin/python3

# Tools required
# "libc6-dev gcc libcurl3" for dmd
# "libgmp3-dev" for msat
RUN apt-get install -qq wget git unzip && \
    apt-get install -qq libc6-dev gcc libcurl3 && \
    apt-get install -qq libgmp3-dev && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir /app

WORKDIR /app

# DMD 2.080.1
RUN wget -q http://downloads.dlang.org/releases/2018/dmd_2.080.0-0_amd64.deb && \
    apt-get install -qq ./dmd_2.080.0-0_amd64.deb && \
    rm dmd_2.080.0-0_amd64.deb

# Pyd v0.13.0
RUN wget -q https://github.com/ariovistus/pyd/archive/v0.13.0.zip && \
    unzip v0.13.0.zip && \
    rm v0.13.0.zip && \
    cd pyd-0.13.0 && \
    python3 setup.py install

WORKDIR /app

# Psipy @ 89f4ca4
RUN git clone https://github.com/ML-KULeuven/psipy.git && \
    cd psipy && \
    git checkout 89f4ca41 && \
    git submodule update --init --recursive && \
    python3 psipy/build_psi.py && \
    python3 setup.py install && \
    echo "export \"PYTHONPATH=/app/psipy/build/lib.linux-x86_64-3.7:${PYTHONPATH}\"" >> /root/.bashrc

# Python dependencies
RUN python3.7 -m pip install -q -U pip && \
    python3.7 -m pip install -q ipython && \
    python3.7 -m pip install -q pysmt && \
    pysmt-install --msat --confirm-agreement

CMD bash