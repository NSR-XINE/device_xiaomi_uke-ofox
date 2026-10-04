#!/system/bin/sh

DEBUG=0
[ "$DEBUG" = "1" ] && set -o xtrace

LOGMSG() {
	echo "I:touch_init: $@" >> /tmp/recovery.log
}

LOGMSG "--- Touch initialization start ---"

# Step 1: Mount dlkm partitions (vendor_dlkm / system_dlkm) if needed
mount_dlkm_partitions() {
	slot=$(getprop ro.boot.slot_suffix)
	[ -z "$slot" ] && slot="_a"

	if [ ! -d /vendor_dlkm/lib/modules ]; then
		mkdir -p /vendor_dlkm
		for dev in "/dev/block/mapper/vendor_dlkm$slot" \
		           "/dev/block/mapper/vendor_dlkm" \
		           "/dev/block/bootdevice/by-name/vendor_dlkm$slot" \
		           "/dev/block/by-name/vendor_dlkm$slot"; do
			if [ -b "$dev" ]; then
				mount -t erofs -o ro "$dev" /vendor_dlkm 2>/dev/null || \
				mount -t ext4 -o ro "$dev" /vendor_dlkm 2>/dev/null
				if [ -d /vendor_dlkm/lib/modules ]; then
					LOGMSG "Mounted vendor_dlkm from $dev"
					break
				fi
			fi
		done
		if [ ! -d /vendor_dlkm/lib/modules ]; then
			mount /vendor_dlkm 2>/dev/null
		fi
	fi

	if [ ! -d /system_dlkm/lib/modules ]; then
		mkdir -p /system_dlkm
		for dev in "/dev/block/mapper/system_dlkm$slot" \
		           "/dev/block/mapper/system_dlkm" \
		           "/dev/block/bootdevice/by-name/system_dlkm$slot" \
		           "/dev/block/by-name/system_dlkm$slot"; do
			if [ -b "$dev" ]; then
				mount -t erofs -o ro "$dev" /system_dlkm 2>/dev/null || \
				mount -t ext4 -o ro "$dev" /system_dlkm 2>/dev/null
				if [ -d /system_dlkm/lib/modules ]; then
					LOGMSG "Mounted system_dlkm from $dev"
					break
				fi
			fi
		done
		if [ ! -d /system_dlkm/lib/modules ]; then
			mount /system_dlkm 2>/dev/null
		fi
	fi
}

# Step 2: Force-load touch driver chain in strict dependency order
# nt36532_touch -> xiaomi_touch, qti_battery_charger, msm_drm, metis
# xiaomi_touch -> panel_event_notifier, miev
ensure_touch_modules() {
	MODULE_DIRS="/vendor/lib/modules /vendor_dlkm/lib/modules /system_dlkm/lib/modules /lib/modules"
	DRIVERS="panel_event_notifier miev metis msm_drm qti_battery_charger xiaomi_touch nt36532_touch"

	for d in $DRIVERS; do
		d_clean="${d//-/_}"
		if lsmod | grep -q "^${d_clean} "; then
			LOGMSG "Module $d already loaded"
			continue
		fi

		found_path=""
		for mdir in $MODULE_DIRS; do
			if [ -d "$mdir" ]; then
				found=$(find "$mdir" -name "$d.ko" 2>/dev/null | head -n 1)
				if [ -n "$found" ] && [ -f "$found" ]; then
					found_path="$found"
					break
				fi
			fi
		done

		if [ -n "$found_path" ]; then
			insmod "$found_path" 2>/dev/null
			if lsmod | grep -q "^${d_clean} "; then
				LOGMSG "Successfully inserted: $d ($found_path)"
			else
				LOGMSG "insmod failed for: $d ($found_path)"
			fi
		else
			LOGMSG "Module not found in search paths: $d"
		fi
	done
}

# Step 3: Wait for touch sysfs node to appear
wait_for_touch_device() {
	local count=0
	while [ $count -lt 30 ]; do
		if [ -d /sys/class/touch/touch_dev ]; then
			LOGMSG "Touch device appeared after ${count}00ms"
			return 0
		fi
		usleep 100000 2>/dev/null || sleep 1
		count=$((count + 1))
	done
	LOGMSG "WARNING: /sys/class/touch/touch_dev did not appear within timeout"
	return 1
}

# Step 4: Apply permissions to character devices and sysfs nodes
apply_touch_permissions() {
	if [ -f /odm/etc/touch_perms.sh ]; then
		sh /odm/etc/touch_perms.sh
		LOGMSG "Applied touch permissions via touch_perms.sh"
	fi
	[ -e /dev/xiaomi-touch ] && chmod 0666 /dev/xiaomi-touch
	[ -e /dev/uinput ] && chmod 0666 /dev/uinput
}

# Step 5: Detect panel vendor and set required vendor properties
update_panel_info() {
	if [ -f /odm/etc/init.panel_info.sh ]; then
		sh /odm/etc/init.panel_info.sh
		LOGMSG "Panel info updated: vendor=$(getprop vendor.panel.vendor), color=$(getprop vendor.panel.color)"
	fi
}

# Step 6: Start/restart Xiaomi touchfeature service
ensure_touch_service() {
	TOUCH_SVC=$(getprop init.svc.touchfeature-service)
	if [ "$TOUCH_SVC" != "running" ]; then
		setprop ctl.start touchfeature-service
		LOGMSG "Started touchfeature-service"
	elif [ -x /system/bin/logcat ] && logcat -d 2>/dev/null | grep -q "thp hal init failed"; then
		setprop ctl.stop touchfeature-service
		sleep 1
		setprop ctl.start touchfeature-service
		LOGMSG "Restarted touchfeature-service after THP failure"
	fi
}

# Step 7: Ensure xiaomi-uinput is running
ensure_uinput_service() {
	UINPUT_SVC=$(getprop init.svc.xiaomi-uinput)
	if [ "$UINPUT_SVC" != "running" ]; then
		setprop ctl.start xiaomi-uinput
		LOGMSG "Started xiaomi-uinput"
	fi
}

# Step 8: Start watchdog to keep touch stack alive throughout recovery session
start_watchdog() {
	if [ -f /system/bin/touch_watchdog.sh ]; then
		if ! pgrep -f touch_watchdog.sh >/dev/null 2>&1; then
			/system/bin/touch_watchdog.sh </dev/null >/dev/null 2>&1 &
			LOGMSG "Started touch_watchdog.sh"
		fi
	fi
}

# Execution flow
mount_dlkm_partitions
ensure_touch_modules
wait_for_touch_device
apply_touch_permissions
update_panel_info
ensure_touch_service
ensure_uinput_service
start_watchdog

[ -f /sbin/prune_historic_logs.sh ] && /sbin/prune_historic_logs.sh 10 2>/dev/null

LOGMSG "--- Touch initialization end ---"
exit 0
