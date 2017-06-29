#!/bin/bash

# Copies all the stuff that's needed by the bootloader to the correct directory so that it
# doesn't need to be typed in manually. 

cd ~/scripts/

./add-custom-setup.sh

cd ~/repos/P032-Source/
./build.sh --package production

cd ~/repos/P032-Source/out

cp Birth_Certificate.tar.gz /tftpboot/.
echo "Copied Birth_Certificate.tar.gz"
cp P032_Bootloader.tar.gz /tftpboot/.
echo "Copied P032_Bootloader.tar.gz"
cp P032_Platform.tar.gz /tftpboot/.
echo "Copied P032_Platform.tar.gz"

echo "Files installed into tftpboot directory"

