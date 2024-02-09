ARG parent_image
FROM $parent_image

RUN apt-get update && \
    apt-get install -y \
        build-essential \
        python3-dev \
        # python3-pip \
        python3-setuptools \
        # nvidia-driver-535 \
        automake \
        cmake \
        git \
        flex \
        bison \
        libglib2.0-dev \
        libpixman-1-dev \
        cargo \
        libgtk-3-dev \
        # for QEMU mode
        ninja-build \
        gcc-$(gcc --version|head -n1|sed 's/\..*//'|sed 's/.* //')-plugin-dev \
        libstdc++-$(gcc --version|head -n1|sed 's/\..*//'|sed 's/.* //')-dev

# Clone your fuzzers sources.
RUN git clone https://github.com/SecurityLab-UCD/AFLplusplus.git /afl && \
    cd /afl && \
    git checkout 3b8b3930db47fd9b9935f3d6f8b644e8ced05cb0 || \
    true

RUN git clone https://github.com/SecurityLab-UCD/structureLLM.git /afl/structureLLM && \
    git checkout d15a0781424c6013df1a8045d0f67610fdf7bf7e  || \
    true

# Build without Python support as we don't need it.
# Set AFL_NO_X86 to skip flaky tests.
RUN cd /afl && \
    unset CFLAGS CXXFLAGS && \
    export CC=clang AFL_NO_X86=1 && \
    PYTHON_INCLUDE=/ make && \
    cp utils/aflpp_driver/libAFLDriver.a /

RUN cd /afl/custom_mutators/aflpp && make