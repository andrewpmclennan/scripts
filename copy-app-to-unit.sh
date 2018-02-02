#!/bin/bash

date

if [ -z $UNIT_IP_ADDRESS ]; then
	export UNIT_IP_ADDRESS=192.168.2.37
fi
echo "Copy file to the SmartHub - IP: $UNIT_IP_ADDRESS".

scp ~/repos/P032-Source/Application/out/app/bin/P032_App root@$UNIT_IP_ADDRESS:~/.
#scp ~/repos/P032-Source/Application/out/app/bin/P032_Pjsip root@192.168.2.13:~/.
#scp ~/repos/P032-Source/Application/out/app/bin/gsm_application_target root@192.168.2.13:~/.

echo "Files copied, moving to location"

ssh root@$UNIT_IP_ADDRESS '/bin/bash -s' < ~/scripts/remote_commands.sh


