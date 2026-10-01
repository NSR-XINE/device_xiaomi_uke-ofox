#!/system/bin/sh

SCRIPT_NAME="$(basename "$0")"

LOGMSG() {
    echo "I:$@" >> /tmp/recovery.log
}

LOGMSG "---$SCRIPT_NAME start---"

if [ -s /tmp/recovery_backup.img ]; then
	for slot in _a _b; do
		REC_PART=""
		if [ -e /dev/block/bootdevice/by-name/recovery${slot} ]; then
			REC_PART="/dev/block/bootdevice/by-name/recovery${slot}"
		elif [ -e /dev/block/bootdevice/by-name/init_boot${slot} ]; then
			REC_PART="/dev/block/bootdevice/by-name/init_boot${slot}"
		fi

		if [ -n "$REC_PART" ]; then
			LOGMSG "Restoring recovery to ${REC_PART}..."
			if dd if="/tmp/recovery_backup.img" of="${REC_PART}" bs=1M; then
				sync
			else
				LOGMSG "Failed to flash to ${REC_PART}..."
			fi
		else
			LOGMSG "Recovery/init_boot partition not found for slot ${slot}, skipping restore..."
		fi
	done
else
	LOGMSG "Unable to find the recovery backup"
fi

# LOGMSG "Clearing previous DFE installation logs..."
# rm -rf /sdcard/neo_file_*

# LOGMSG "Setting instructions for next reboot..."
# echo "install /FFiles/DFE.zip" > /cache/recovery/openrecoveryscript

# LOGMSG "Preserving recovery.log before recovery reboot..."
LOGMSG "---$SCRIPT_NAME end---"
# mkdir -p /persist/AERA/logs
# cp /tmp/recovery.log "/persist/AERA/logs/dfe_recovery_$(date +"%Y%m%d_%H%M%S").log"

# reboot recovery
