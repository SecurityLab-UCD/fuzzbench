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
    git checkout 523ee4c8fb27fad2a78290650fe1aab641dfa02d || \
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
    git checkout 54bf86b0ac7fc4937b11fda9c1d874c08110ccbf  || \
    true