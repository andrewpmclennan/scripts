#!/bin/bash

IP_ADDRESS="192.168.2.37"

echo "Copy setting file to unit"

cd ~

scp ~/my_modifications/ipu_config.json root@$IP_ADDRESS:/opt/tunstall/configs/.

