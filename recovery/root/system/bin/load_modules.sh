#!/system/bin/sh

DEBUG=0
[ "$DEBUG" = "1" ] && set -o xtrace;

LOGMSG() {
	echo "I:$@" >> /tmp/recovery.log
}

quit() {
	LOGMSG "$@ is loaded";
}

load_drivers() {
	local path1=/lib/modules;
	local path2=/vendor/lib/modules/1.1;
	local path3=/vendor/lib/modules;
	local modules="qcom_q6v5 qcom_q6v5_pas adsp_loader_dlkm adsp_sleepmon qti_battery_charger xiaomi_touch nt36532_touch"

	# loop through the modules
	for i in $modules; do
		# check whether the module is already loaded
		if lsmod | grep "^$i"; then
			quit "$i"
			continue
		fi

		# try modprobe with dependency resolution
		modprobe -d "$path3" "$i" 2>/dev/null
		if lsmod | grep "^$i"; then
			quit "$i"
			continue
		fi

		# try to load the module via direct insmod
		for p in "$path1" "$path2" "$path3"; do
			if [ -f "$p/$i.ko" ]; then
				insmod "$p/$i.ko" 2>/dev/null
				if lsmod | grep "^$i"; then
					quit "$i"
					break
				fi
			fi
		done

		# check if loaded
		if ! lsmod | grep "^$i"; then
			LOGMSG "$i failed to load"
		fi
	done
}

SCRIPT_NAME="$(basename "$0")"

LOGMSG "---$SCRIPT_NAME start---"
load_drivers;
setprop vendor.modules.loaded true
setprop twrp.modules.loaded true
LOGMSG "---$SCRIPT_NAME end---"
exit 0
