###
### Dockerfile for Tock
###

# Use Ubuntu 22.04
FROM ubuntu:22.04

LABEL maintainer="Tock Project Developers <tock-dev@googlegroups.com>"
LABEL version="0.1"
LABEL description="Dockerfile for Tock"

# Disable Prompt During Packages Installation
ARG DEBIAN_FRONTEND=noninteractive
# Update Ubuntu Software repository
RUN apt update

# Install our toolchains
RUN apt install -y gcc-arm-none-eabi gcc-riscv64-unknown-elf

# Install needed tools
RUN apt install -y git build-essential wget rsync zip
RUN apt install -y python3 python3-pip

# Setup Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# Clone and compile the kernel
RUN git clone https://github.com/tock/tock
RUN cd tock/boards/nordic/nrf52840dk && make
RUN cd tock/boards/opentitan/earlgrey-cw310 && make

# Clone and build libtock-c
RUN git clone https://github.com/tock/libtock-c
RUN cd libtock-c/examples/c_hello && make
RUN cd libtock-c/examples/cxx_hello && make

# Clone and build libtock-rs
RUN git clone https://github.com/tock/libtock-rs
RUN cd libtock-rs && make nrf252840 EXAMPLE=blink

# Install tockloader
RUN pip install tockloader
