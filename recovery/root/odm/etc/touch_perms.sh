#!/system/bin/sh
# uke: apply touch node permissions for whatever actually exists on this
# device. The stock rc block chowns a fixed phone-oriented list
# (tp_dev/fod_status, xiaomi-touch-knock, ...); the first missing path makes
# init abort the whole action, so later nodes (incl. abnormal_event, which
# the THP daemon must open) stay root-owned and touch never works.
# This script only touches nodes that exist and always exits 0.

# Character devices
for f in /dev/xiaomi-touch /dev/xiaomi-touch-knock /dev/xiaomi-thp \
         /proc/tp_selftest /proc/tp_selftest_1; do
    if [ -e "$f" ]; then
        chown system:system "$f" 2>/dev/null
        chmod 0666 "$f" 2>/dev/null
    fi
done

# The THP daemon, xiaomi-uinput and HAL clients need access to these device nodes
[ -e /dev/xiaomi-touch ] && chmod 0666 /dev/xiaomi-touch
[ -e /dev/uinput ] && chmod 0666 /dev/uinput

# Allow directory traversal
[ -d /sys/class/touch/touch_dev ] && chmod 0755 /sys/class/touch/touch_dev 2>/dev/null
[ -d /sys/class/touch/tp_dev ] && chmod 0755 /sys/class/touch/tp_dev 2>/dev/null

# touch sysfs nodes (xiaomi_touch module)
for f in /sys/class/touch/touch_dev/* /sys/class/touch/tp_dev/*; do
    [ -e "$f" ] || continue
    case "$f" in
        */uevent|*/power|*/power/*) continue ;;
    esac
    chown system:system "$f" 2>/dev/null
    chmod 0666 "$f" 2>/dev/null
done

# Virtual keypad status node
f=/sys/devices/virtual/keyboard/keypad/keyboard_status_param
if [ -e "$f" ]; then
    chown system:system "$f" 2>/dev/null
    chmod 0664 "$f" 2>/dev/null
fi

exit 0
