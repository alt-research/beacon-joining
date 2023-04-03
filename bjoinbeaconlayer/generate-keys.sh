#!/bin/bash

IMAGE=$(grep "image:" docker-compose.yaml | awk '{print $2}')
ENV_FILE="vars.env"

mkdir -p ./keystore
chmod 0755 ./keystore

if [[ -e "./MNEMONIC" ]]; then
    MNEMONIC=$(cat ./MNEMONIC)
    echo "using existing mnemonic from file ./MNEMONIC"
else
    MNEMONIC=$(docker run --rm $IMAGE key generate | grep -oP 'Secret phrase:\s+\K.*')
    echo $MNEMONIC > MNEMONIC
    echo "generated new mnemonic: $MNEMONIC"
fi

NODEKEY=$(docker run --rm $IMAGE key inspect --scheme ed25519 "$MNEMONIC//nodekey" | grep -oP 'Secret seed:\s+\K.*')
GRAN_ADDR=$(docker run --rm $IMAGE key inspect --scheme ed25519 "$MNEMONIC//grandpa" | grep -oP 'SS58 Address:\s+\K.*')
AURA_ADDR=$(docker run --rm $IMAGE key inspect --scheme sr25519 "$MNEMONIC//aura"    | grep -oP 'SS58 Address:\s+\K.*')

echo > $ENV_FILE
echo "# Aura    SS58 Address: $AURA_ADDR" >> $ENV_FILE
echo "# Grandpa SS58 Address: $GRAN_ADDR" >> $ENV_FILE
echo "MNEMONIC='$MNEMONIC'" >> $ENV_FILE
echo >> $ENV_FILE
echo '# nodekey is generated from command:' >> $ENV_FILE
echo '# docker run --rm $IMAGE key inspect --scheme ed25519 "$MNEMONIC//nodekey"' >> $ENV_FILE
echo "NODEKEY='$NODEKEY'" >> $ENV_FILE
