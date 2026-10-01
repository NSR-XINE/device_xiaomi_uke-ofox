#!/system/bin/sh

SCRIPT_NAME="$(basename "$0")"

LOGMSG() {
    echo "I:$@" >> /tmp/recovery.log
}

LOGMSG "---$SCRIPT_NAME start---"

LOGMSG "Resetting SPL date to prevent anti-rollback protection..."
resetprop ro.build.version.security_patch 2023-12-31

# LOGMSG "Formatting /metadata..."
# make_f2fs /dev/block/bootdevice/by-name/metadata

D="/metadata/ota"

mount /metadata 2>/dev/null

LOGMSG "Checking for stale OTA metadata which may block ROM install..."
if [ -d "$D" ]; then
    LOGMSG "Wiping $D..."
    rm -rf "$D" 2>/dev/null
fi

LOGMSG "Detecting active boot slot..."
slot="$(getprop ro.boot.slot_suffix)"
if [ -z "$slot" ]; then
    LOGMSG "Unable to detect active boot slot; skipping recovery backup..."
else
    LOGMSG "Active boot slot: $slot"

    LOGMSG "Backing up recovery before ROM overwrite..."
    REC_PART=""
    if [ -e /dev/block/bootdevice/by-name/recovery${slot} ]; then
        REC_PART="/dev/block/bootdevice/by-name/recovery${slot}"
    elif [ -e /dev/block/bootdevice/by-name/init_boot${slot} ]; then
        REC_PART="/dev/block/bootdevice/by-name/init_boot${slot}"
    fi

    if [ -n "$REC_PART" ]; then
        if dd if="$REC_PART" of="/tmp/recovery_backup.img" bs=1M; then
            sync
            LOGMSG "Recovery backup completed from $REC_PART"
        else
            LOGMSG "Failed to back up recovery from $REC_PART"
        fi
    else
        LOGMSG "Recovery/init_boot partition not found; skipping backup..."
    fi
fi

LOGMSG "---$SCRIPT_NAME end---"
