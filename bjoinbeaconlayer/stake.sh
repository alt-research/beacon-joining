#!/bin/bash
. vars.env

STAKING_AMOUNT=1000
NODE_PORT=9944

# Install altctl
# https://github.com/alt-research/altctl
if [ -x "$(command -v altctl)" ]; then
  printf "altctl - already exist!\n\n"
else
  printf "altctl - please refer to https://github.com/alt-research/altctl if installation fails\n\n"
  MACHINE_OS="$(uname -s)"
  MACHINE_ARCH="$(uname -m)"

  case $MACHINE_ARCH in
  "arm64"|"aarch64")
    case $MACHINE_OS in
    "Darwin")
      echo "Darwin ARM64"
      gh -R alt-research/altctl release download --clobber -p "altctl*darwin-arm64.tar.gz"
      tar -xvf altctl*darwin-arm64.tar.gz
      ;;

    *)
      echo "Linux ARM"
      gh -R alt-research/altctl release download --clobber -p "altctl*linux-arm.tar.gz"
      tar -xvf altctl*linux-arm.tar.gz
      ;;
    esac
    echo "Please use ./altctl/bin/altctl"
    ;;

  *)
    case $MACHINE_OS in
    "Darwin")
      echo "Darwin x86_64"
      gh -R alt-research/altctl release download --clobber -p "altctl*darwin-x86_64.tar.gz"
      tar -xvf altctl*darwin-x86_64.tar.gz
      echo "Please use ./altctl/bin/altctl"
      ;;
    *)
      echo "Linux AMD64"
      gh -R alt-research/altctl release download --clobber -p "altctl*amd64.deb"
      sudo dpkg -i altctl*amd64.deb
      rm altctl*amd64.deb
      altctl --version
      ;;
    esac
    ;;
  esac
fi

set -x
printf "Generating session key"
altctl author rotate-keys --endpoint ws://localhost:$NODE_PORT > session_key.txt

printf "Submitting extrinsic session::setKeys"
altctl session set-keys --endpoint ws://localhost:$NODE_PORT \
  --keys=$(head -n 1 session_key.txt) \
  --proof=0x \
  --seed="$MNEMONIC"

printf "Submitting extrinsic altBeaconStaking::joinCanditates"
altctl join-candidate --endpoint ws://localhost:$NODE_PORT \
  --bound="$STAKING_AMOUNT" \
  --seed="$MNEMONIC"
set +x
