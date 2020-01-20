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
# "m4" for latte
RUN apt-get install -qq vim wget git unzip && \
    apt-get install -qq libc6-dev gcc libcurl3 && \
    apt-get install -qq libgmp3-dev && \
    apt-get install -qq m4 && \
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

# latte 1.7.5
RUN wget -q "https://github.com/latte-int/latte/releases/download/version_1_7_5/latte-integrale-1.7.5.tar.gz" && \
    tar -xvzf latte-integrale-1.7.5.tar.gz && \
    rm latte-integrale-1.7.5.tar.gz && \
    cd latte-integrale-1.7.5 && \
    ./configure && \
    # ./configure --enable-cxx && \
    make && \
    make install && \
    echo "export \"PATH=/app/latte-integrale-1.7.5/dest/bin:${PATH}\"" >> /root/.bashrc

# Psipy @ 89f4ca4
RUN git clone https://github.com/ML-KULeuven/psipy.git && \
    cd psipy && \
    git checkout 89f4ca41 && \
    git submodule update --init --recursive && \
    python3 psipy/build_psi.py && \
    python3 setup.py install && \
    echo "export \"PYTHONPATH=/app/psipy/build/lib.linux-x86_64-3.7:${PYTHONPATH}\"" >> /root/.bashrc

# Python dependencies (pysmt)
RUN python3.7 -m pip install -q -U pip setuptools && \
    python3.7 -m pip install -q ipython && \
    python3.7 -m pip install -q pysmt && \
    pysmt-install --msat --confirm-agreement && \
    python3.7 -m pip install problog typing

# wmipa @ b2999a1
RUN git clone https://github.com/unitn-sml/wmi-pa.git && \
    cd wmi-pa && \
    git checkout b2999a1 && \
    python3 setup.py install

CMD bash