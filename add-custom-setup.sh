#!/bin/bash

echo "Setting up custom setup to stop requirement to write all the nonsense in by hand."

cd ~/repos/P032-Source/Application/out/app/scripts/
mv -v startup.sh startup.sh.orig
cp -v ~/my_modifications/startup.sh .

cd ~/repos/P032-Source/Application/out/app/configs/
mv -v ipu_config.json ipu_config.json.orig
cp -v ~/my_modifications/ipu_config.json .

cd ~/repos/P032-Source/Platform/out/uniflash/
mv -v Birth_Certificate.tar.gz Birth_Certificate.tar.gz.old
cp -v ~/my_modifications/Birth_Certificate.tar.gz .

echo "All custom settings applied"

