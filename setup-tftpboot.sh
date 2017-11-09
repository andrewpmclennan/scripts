#!/bin/bash

# Copies all the stuff that's needed by the bootloader to the correct directory so that it
# doesn't need to be typed in manually. 

cd ~/scripts/

#./add-custom-setup.sh

cd ~/repos/P032-Source/
#./build.sh --package production

cd ~/repos/P032-Source/out

cp * /tftpboot/.
echo "Copied Build artifacts to /tftpboot directory"

cd /tftpboot/
rm flasher.sh
tar -xf flasher.tar.gz

echo "Files installed into tftpboot directory"

