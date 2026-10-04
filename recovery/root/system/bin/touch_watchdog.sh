#!/system/bin/sh
# uke: touch watchdog for recovery.
#
# The xiaomi-uinput bridge sends an active-mode keepalive ioctl every 15s
# which keeps the THP daemon out of doze mode. This watchdog ensures both
# touchfeature-service and xiaomi-uinput stay running and healthy.

LOGFILE=/tmp/recovery.log

while true; do
	sleep 15

	# 1. Watch touchfeature-service
	svc=$(getprop init.svc.touchfeature-service)
	if [ "$svc" != "running" ]; then
		# Re-apply permissions first in case nodes were re-created
		[ -f /odm/etc/touch_perms.sh ] && sh /odm/etc/touch_perms.sh
		setprop ctl.start touchfeature-service
		echo "I:touch_watchdog: touchfeature-service was $svc, restarted" >> "$LOGFILE"
	fi

	# 2. Watch xiaomi-uinput
	uinput_svc=$(getprop init.svc.xiaomi-uinput)
	if [ "$uinput_svc" != "running" ]; then
		setprop ctl.start xiaomi-uinput
		echo "I:touch_watchdog: xiaomi-uinput was $uinput_svc, restarted" >> "$LOGFILE"
	fi
done
