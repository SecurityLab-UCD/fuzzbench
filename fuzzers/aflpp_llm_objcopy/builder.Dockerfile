ARG parent_image
FROM $parent_image

RUN apt-get update && \
    apt-get install -y \
        build-essential \
        python3-dev \
        python3-setuptools \
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
    git checkout 0a53b3ff8f2f977af98a00c212524f9362a24653 || \
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
    cd /afl/structureLLM && \
    git checkout 0b6f2788cbdd81039b0ff902e01d1413b634b5fe  && \
    cd ..