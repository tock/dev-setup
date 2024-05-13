#!/usr/bin/env bash

set -x
set -e

# From https://unix.stackexchange.com/a/137639 ----------------------
function fail {
  echo $1 >&2
  exit 1
}

function retry {
  local n=1
  local max=10
  local delay=15
  while true; do
    "$@" && break || {
      if [[ $n -lt $max ]]; then
        ((n++))
        echo "Command failed. Attempt $n/$max:"
        sleep $delay;
      else
        fail "The command has failed after $n attempts."
      fi
    }
  done
}
# -------------------------------------------------------------------

set +e
echo "Using Google DNS to avoid around DNS resolution issues."
cat /etc/resolv.conf | sudo tee /etc/resolv.conf.bak
sudo chattr -i /etc/resolv.conf
sudo rm /etc/resolv.conf
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf
sudo chattr +i /etc/resolv.conf
set -e

echo "Provisioning Tock development VM..."
cd /home/tock/

retry git clone https://github.com/tock/tock ./tock
retry git clone https://github.com/tock/libtock-c ./libtock-c
retry git clone https://github.com/tock/libtock-rs ./libtock-rs

echo "Installing Tockloader"
retry sudo pip3 install tockloader

echo "Installing rustup"
curl https://sh.rustup.rs -sSf | sh -s -- -y

echo "Source the Rust setup"
source /home/tock/.cargo/env

echo "Build the libtock-c example app, downloading toolchains and elf2tab"
pushd libtock-c/examples/c_hello
retry make
popd

echo "Build the nRF52840DK Tock board, which will download the Rust toolchain"
pushd tock/boards/nordic/nrf52840dk
retry make
popd

set +e
echo "Restoring DNS configuration."
sudo chattr -i /etc/resolv.conf
sudo rm /etc/resolv.conf
sudo mv /etc/resolv.conf.bak /etc/resolv.conf
sudo chattr +i /etc/resolv.conf
set -e
