#!/system/bin/sh

DEBUG=0
[ "$DEBUG" = "1" ] && set -o xtrace

LOGMSG() {
	echo "I:load_modules: $@" >> /tmp/recovery.log
}

load_drivers() {
	local search_paths="/vendor/lib/modules /vendor_dlkm/lib/modules /system_dlkm/lib/modules /lib/modules"
	local modules="panel_event_notifier miev metis msm_drm qti_battery_charger xiaomi_touch nt36532_touch adsp_sleepmon qcom_q6v5 qcom_q6v5_pas si_haptic"

	for mod in $modules; do
		local clean_mod="${mod//-/_}"
		if lsmod | grep -q "^${clean_mod} "; then
			LOGMSG "$mod is already loaded"
			continue
		fi

		local loaded=0
		for p in $search_paths; do
			if [ -f "$p/$mod.ko" ]; then
				insmod "$p/$mod.ko" 2>/dev/null
				if lsmod | grep -q "^${clean_mod} "; then
					LOGMSG "$mod loaded from $p"
					loaded=1
					break
				fi
			fi
		done

		if [ $loaded -eq 0 ]; then
			LOGMSG "$mod failed to load"
		fi
	done
}

SCRIPT_NAME="$(basename "$0")"

LOGMSG "---$SCRIPT_NAME start---"
load_drivers
LOGMSG "---$SCRIPT_NAME end---"
exit 0
