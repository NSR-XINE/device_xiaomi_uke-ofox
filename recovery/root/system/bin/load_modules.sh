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
	local modules="xiaomi_touch nt36532_touch qti_battery_charger adsp_sleepmon qcom_q6v5 qcom_q6v5_pas si_haptic"

	# loop through the modules
	for i in $modules; do
		# check whether the module is already loaded
		if lsmod | grep "^$i"; then
			quit "$i"
			continue
		fi

		# try to load the module
		insmod "$path1/$i.ko" 2>/dev/null
		if lsmod | grep "^$i"; then
			quit "$i"
			continue
		fi

		insmod "$path2/$i.ko" 2>/dev/null
		if lsmod | grep "^$i"; then
			quit "$i"
			continue
		fi

		insmod "$path3/$i.ko" 2>/dev/null
		if lsmod | grep "^$i"; then
			quit "$i"
			continue
		fi

		# module failed to load from all paths
		LOGMSG "$i failed to load"
	done
}

SCRIPT_NAME="$(basename "$0")"

LOGMSG "---$SCRIPT_NAME start---"
load_drivers;
LOGMSG "---$SCRIPT_NAME end---"
exit 0
