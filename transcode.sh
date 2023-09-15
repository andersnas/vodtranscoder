#!/bin/bash

# Validate input arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <PATH/FILENAME> <NUMBER_OF_MACHINES>"
    exit 1
fi

random=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 8)
echo "Random directory: $random"
mkdir $random
cp * $random

cd $random
./automate.sh $1 $2
cd ..
rm -rf $random
