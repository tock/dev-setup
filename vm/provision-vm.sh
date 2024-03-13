#!/usr/bin/env bash

echo "Provisioning Tock development VM..."
cd /home/tock/

echo "Cloning git repos"
git clone https://github.com/tock/tock ./tock
git clone https://github.com/tock/libtock-c ./libtock-c
git clone https://github.com/tock/libtock-rs ./libtock-rs

echo "Installing rustup"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

echo "Installing Tockloader"
sudo pip3 install tockloader

echo "Installing GCC toolchains"
sudo apt install -y gcc-arm-none-eabi gcc-riscv64-unknown-elf

echo "Building kernel"
pushd ./tock/boards/nordic/nrf52840dk/ && make && popd
pushd ./tock/boards/opentitan/earlgrey-cw310/ && make && popd

echo "Building libtock-c app"
pushd ./libtock-c/examples/c_hello/ && make && popd
pushd ./libtock-c/examples/cxx_hello/ && make && popd

echo "Building libtock-rs app"
pushd ./libtock-rs/ && make nrf52840 EXAMPLE=blink && popd
