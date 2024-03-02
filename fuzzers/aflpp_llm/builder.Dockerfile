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
    git checkout d1365ad8890c250189431674b09e45d20515c4b1 || \
    true

# Build without Python support as we don't need it.
# Set AFL_NO_X86 to skip flaky tests.
RUN cd /afl && \
    unset CFLAGS CXXFLAGS && \
    export CC=clang AFL_NO_X86=1 && \
    PYTHON_INCLUDE=/ make && \
    cp utils/aflpp_driver/libAFLDriver.a /

RUN cd /afl/custom_mutators/aflpp && make

RUN git clone https://github.com/SecurityLab-UCD/structureLLM.git /afl/structureLLM && \
    git checkout 619e36184d3872c188a35353c0588ff6b1805791  || \
    true