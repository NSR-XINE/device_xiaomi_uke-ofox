#!/system/bin/sh

SCRIPT_NAME="$(basename "$0")"

LOGMSG() {
    echo "I:$@" >> /tmp/recovery.log
}

LOGMSG "---$SCRIPT_NAME start---"

for slot in _a _b; do
	LOGMSG "Restoring OrangeFox to slot ${slot}..."
	dd if="/tmp/fox_backup.img" of="/dev/block/bootdevice/by-name/recovery${slot}" bs=1M
	sync
	sleep 1
done

LOGMSG "Setting instructions for next reboot..."
echo "install /FFiles/DFE.zip" > /cache/recovery/openrecoveryscript
echo "noForceReboot" >> /cache/recovery/openrecoveryscript

LOGMSG "Preserving recovery.log before recovery reboot..."
LOGMSG "---$SCRIPT_NAME end---"
mkdir -p /sdcard/Fox/logs
cp /tmp/recovery.log "/sdcard/Fox/logs/recovery_$(date +"%Y%m%d_%H%M%S").log"

reboot recovery
