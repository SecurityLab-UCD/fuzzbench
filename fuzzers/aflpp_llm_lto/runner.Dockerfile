# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM gcr.io/fuzzbench/base-image

RUN pip install triton>=2.0.0
RUN pip install torch>=2.0.1 torchvision>=0.15.2 torchaudio>=2.0.2 --index-url https://download.pytorch.org/whl/nightly/cu118
RUN pip install datasets>=2.14.5
RUN pip install tqdm==4.65.0
RUN pip install peft==0.6.2
RUN pip install accelerate==0.24.1
RUN pip install transformers==4.35.0
RUN pip install trl==0.7.2
RUN pip install tyro
RUN pip install typing
RUN pip3 install sysv-ipc
RUN pip install bitsandbytes
    # cd /afl/structureLLM && pip3 install -r requirement.txt
# This makes interactive docker runs painless:
ENV LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/out"
ENV AFL_MAP_SIZE=16777216
#2621440
ENV PATH="$PATH:/out"
ENV AFL_SKIP_CPUFREQ=1
ENV AFL_I_DONT_CARE_ABOUT_MISSING_CRASHES=1
# ENV AFL_TESTCACHE_SIZE=2
ENV AFL_NO_UI=1
# ENV AFL_CUSTOM_MUTATOR_LIBRARY=custom_mutators/aflpp/aflpp-mutator.so
RUN apt-get update && \
    apt install -y unzip git gdb joe wget lsb-release software-properties-common
    # apt-get install libcublas-12-3
RUN wget https://apt.llvm.org/llvm.sh
RUN chmod +x llvm.sh
RUN ./llvm.sh 17 all

RUN wget https://raw.githubusercontent.com/TimDettmers/bitsandbytes/main/install_cuda.sh
RUN bash install_cuda.sh 118 /usr/local

ENV LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/cuda-11.8/lib64"