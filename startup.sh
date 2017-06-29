#!/bin/sh
#*********************************************************************
# FILENAME:		startup.sh &
#
# AUTHOR:		Tata Elxsi
#
# DESCRIPTION:  This file is used to autorun any application on bootup
#
# CHANGE HISTORY:
#
# Date 	 		Changed By     		Comment
# 29/06/2015 	 	Tata Elxsi         	Created
#
# LAST MODIFIED BY:   	$Author: Tata Elxsi $
#
# CURRENT REVISION:   $Revision: 1.00 $
#
#******************************************************************************
##
##  Tunstall Healthcare
##
#******************************************************************************

#
# Macros to define constant values
#
MAX_RETRY=3
STARTUP_COUNT=0
BOOTPART1=2
BOOTPART2=3
BOOTPART3=5
WDTRETRYCOUNT=3
LAST_REBOOT_STATE=0
PRE_WDRESET=6
TUNSTALL_STATIC_IP_FILE_PATH="/etc/network/static_IP"

#
# Find the fallback partition number
#
function find_prev_boot_part(){
    if [ $1 == $BOOTPART1 ]
    then
        return "${BOOTPART3}"
    elif [ $1 == $BOOTPART2 ]
    then
        return "${BOOTPART1}"
    else
        return "${BOOTPART2}"
    fi
}

# Find the next partition number
function find_next_boot_part(){
    if [ $1 == $BOOTPART1 ]
    then
        return "${BOOTPART2}"
    elif [ $1 == $BOOTPART2 ]
    then
        return "${BOOTPART3}"
    else
        return "${BOOTPART1}"
    fi
}

#
# Create log folder
#
! test -d "/tmp/softupgrade" && mkdir "/tmp/softupgrade"

#
# Export the Application path to Environment
#
export PATH=$PATH:/opt/tunstall/bin

#
# Launch cron job for monitoring logrotate
#
#/etc/init.d/crond start &

#
# Setting default IPU date and time
#
DEFAULT_YEAR=2015
DEFAULT_DATE=2015-01-15
YEAR=`date | awk '{print $6}'`
if [ $YEAR -lt $DEFAULT_YEAR ]
then
logger -p info "Trying to set default year as $DEFAULT_YEAR. Resetting sytem date and time to $DEFAULT_DATE"
/bin/date -s $DEFAULT_DATE
/sbin/hwclock --systohc
logger -p info "hwclock set to `hwclock`"
fi

#
# Check wdtretry variable and do fallback when wdtretry value reaches 3
#
WDT_RETRY=$(fw_printenv wdtretry | awk -F '=' '{print $2}')
if [ "${WDT_RETRY}" == "$WDTRETRYCOUNT" ]
then
    logger -p ERROR "Watchdog counter reached limit. Resetting counter and do fallback"
    /opt/tunstall/scripts/P032_Update_Bootvariable.sh bootswitch 3
	/opt/tunstall/scripts/P032_Update_Bootvariable.sh wdtretry 0
	/opt/tunstall/scripts/P032_Update_Bootvariable.sh bootstatus 1
	sync
	reboot
fi




#
# GPIO MIC CONTROL
#
echo 65 > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio65/direction
echo 0 > /sys/class/gpio/gpio65/value

# Launch gsmMux app
cd /usr/sbin
echo "Configuring GSM Baudrate"
./GSMBaudRateConf_App
#echo "launching gsmMux interface"
#./gsmMuxd -p /dev/ttyO0 -f 64 -b 921600 -s /dev/HL /dev/ptmx /dev/ptmx &

#echo "introducing delay to ensure virtual interface is up"
#sleep 1

#
# Enable Antenna
#
#echo "Enabling Antenna for Boosting signal"
#echo 51 > /sys/class/gpio/export
#echo out > /sys/class/gpio/gpio51/direction
#echo 1 > /sys/class/gpio/gpio51/value
#cat /sys/class/gpio/gpio51/value

# Launch Boot monitor application
# echo "Boot monitor application started...."
# /opt/tunstall/scripts/P032_Bootmonitor.sh

# Testing only will remove later
/etc/init.d/dropbear start &
# /etc/init.d/storage-gadget-init start &
ifconfig

# Stereo Max gain setting
# NB there seems to be a bug in the alsa system whereby unless you lower
# and then raise the volume, it does not do anything. This extra call 
# is to eliminate this bug. Maximum value for volume is 63 (see amixer for
# more details)
/usr/bin/amixer set Master 62
/usr/bin/amixer set Master 63

# Set soft limit to unlimited
ulimit -c unlimited
#ulimit -c 0

# Set path and pattern for core file
#echo "/media/userdata/core.%s.%e.%p.%h.%t" > /proc/sys/kernel/core_pattern
echo "/media/userdata/core" > /proc/sys/kernel/core_pattern

# Log to print the current boot partition
BOOT_PART=$(fw_printenv validbootpart | awk -F '=' '{print $2}')
logger -p info "SoftwareUpgrade: Current boot partition is $BOOT_PART"

# Reset the boot variable since it is fresh bootup
/opt/tunstall/scripts/P032_Update_Bootvariable.sh applaunchcount 0


# Check bootstatus variable to decide if soup.info file needs to be generated
BOOT_STATUS=$(fw_printenv bootstatus | awk -F '=' '{print $2}')
logger -p info "$(basename $0) : ${LINENO} : Current boot status is $BOOT_STATUS"

if [ "${BOOT_STATUS}" == "0" ] || [ "${BOOT_STATUS}" == "1" ] || [ ! -f /opt/tunstall/misc/soup.info ]
then
    chmod +x /opt/tunstall/scripts/generate_soup_info.sh

    # Invoke the script to generate the soup.info file.
    /opt/tunstall/scripts/generate_soup_info.sh

    RetStatus=$?

    if [ "${RetStatus}" != "0" ]
    then
        logger -p warn "$(basename $0) : ${LINENO} : Failed to generate soup.info file"
    else
        logger -p info "$(basename $0) : ${LINENO} : Successfully generated soup.info file"
    fi
else
    logger -p info "$(basename $0) : ${LINENO} : The file soup.info exists."
fi

# Copying the configuration from previous partition in case of partition change for WatchDog reset
# Getting the bootswitch value
BOOT_SWITCH=$(fw_printenv bootswitch | awk -F '=' '{print $2}')
# If bootswitch is 3 and bootstatus is 1 then partition has changed
if [ "${BOOT_SWITCH}" == "3" ] && [ "${BOOT_STATUS}" == "1" ]
then
    logger -p info "Boot partition changed because of WatchDog reboot"
    echo "Boot partition changed because of WatchDog reboot"
    # Updating the bootswitch variable back to 0
    /opt/tunstall/scripts/P032_Update_Bootvariable.sh bootswitch 0
fi
if [ "${BOOT_STATUS}" == "1" ]
then
    logger -p info "Boot partition changed copying config files"
    echo "Boot partition changed copying config file"
    # Finding the next partition
    find_next_boot_part ${BOOT_PART}
    NEXT_BOOT_PART=$?
    mount /dev/mmcblk0p$NEXT_BOOT_PART /mnt
    # Checking the mount status
    if [ $? == 0 ]
    then
        logger -p info "Successfuly mounted to the previous partition"
        cp -f /mnt/opt/tunstall/configs/ipu_config.json /opt/tunstall/configs/ipu_config_previous.json
        logger -p info "Copied config file from previous boot partition to fallback partition"
        # Move the existing static IP file if it is present to the backward
        # partition
        if [ -f /mnt$TUNSTALL_STATIC_IP_FILE_PATH ]
        then
            logger -p info "Startup.sh: Static IP file exists"
            if ! mv -f /mnt$TUNSTALL_STATIC_IP_FILE_PATH $TUNSTALL_STATIC_IP_FILE_PATH
            then
                logger -p info "Startup.sh: Unable to move static IP file"
            else
                /etc/init.d/networking restart
            fi
        else
            logger -p info "Startup.sh: Static IP file does not exist"
        fi
        sync
        umount /mnt
    else
        logger -p info "Failed to  mount to the previous partition"
    fi
fi

function run_app_retries()
{
    # Re-try trice if application failed to launch
    while [ 1 ]
    do
        if [ $STARTUP_COUNT -ge $MAX_RETRY ]
        then
            logger -p info "Startup.sh: Max Application Restart Count Reached..."
            break;
        else
            # Kill RTC if it running
            kill -9 `fuser /dev/rtc0` >> /dev/null 2>&1

            # Call the Tunstall application at boot up
            logger -p info "Startup.sh: Launching Tunstall Application $STARTUP_COUNT..."
            echo "Launching Tunstall Application $STARTUP_COUNT .... "

            cd /opt/tunstall/bin

            # Set executable permission to application
            chmod +x *

            # Launch application
            ./P032_App

            # Read the lastrebootstate value and check if IPU is in pre-watchdog reset
            # state
            LAST_REBOOT_STATE=`fw_printenv lastrebootstate | awk -F '=' '{print $2}'`
            if [ $LAST_REBOOT_STATE -eq $PRE_WDRESET ]
            then
                # Kill any process if it is holding the watchdog device
                kill -9 `fuser /dev/watchdog` >> /dev/null 2>&1
                # Open the watchdog device and wait for it to trigger a reset
                cat > /dev/watchdog
                # If watchdog open fails reboot the IPU
                reboot;
            fi

            # Read the value from boot variable. This is required since the application
            # might have reset it.
            STARTUP_COUNT=`fw_printenv applaunchcount | awk -F '=' '{print $2}'`

            # Increment index if unable to launch application
            STARTUP_COUNT=$[$STARTUP_COUNT + 1]

            # Write the value back to the boot variable. We would need this next time.
            /opt/tunstall/scripts/P032_Update_Bootvariable.sh applaunchcount $STARTUP_COUNT
        fi
    done
    # Fall back to previous partition
    find_prev_boot_part ${BOOT_PART}
    PREV_BOOT_PART=$?
    logger -p info "Startup.sh: Current partition is $BOOT_PART, Fallback partition is $PREV_BOOT_PART"
    # Update the bootstatus variable
    /opt/tunstall/scripts/P032_Update_Bootvariable.sh bootstatus 1

    # Rebooting the IPU
    reboot
}
# to allow serial login, run this as a forked process using '&'
run_app_retries
