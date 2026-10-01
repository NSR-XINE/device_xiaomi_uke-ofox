#
# Copyright (C) 2026 The Android Open Source Project
# Copyright (C) 2026 SebaUbuntu's TWRP device tree generator
#
# SPDX-License-Identifier: Apache-2.0
#

# Tool
TW_INCLUDE_REPACKTOOLS := true
TW_INCLUDE_RESETPROP := true
TW_INCLUDE_LIBRESETPROP := true
TW_INCLUDE_LPDUMP := true
TW_INCLUDE_LPTOOLS := true

# Debug
TARGET_USES_LOGD := true
TWRP_INCLUDE_LOGCAT := true

# Fastbootd
TW_INCLUDE_FASTBOOTD := true

# Other TWRP Configurations
TW_THEME := portrait_hdpi
TW_FRAMERATE := 120
RECOVERY_SDCARD_ON_DATA := true
TARGET_RECOVERY_QCOM_RTC_FIX := true
TW_EXCLUDE_DEFAULT_USB_INIT := true
TW_INCLUDE_NTFS_3G := true
TW_NO_EXFAT_FUSE := false
TW_USE_TOOLBOX := true
TARGET_USES_MKE2FS := true
TW_INPUT_BLACKLIST := "hbtp_vm"
TW_BRIGHTNESS_PATH := "/sys/class/backlight/panel0-backlight/brightness"
TW_MAX_BRIGHTNESS := 2047
TW_EXTRA_LANGUAGES := true
TW_DEFAULT_LANGUAGE := en
TW_DEFAULT_BRIGHTNESS := 200
TW_NO_SCREEN_BLANK := true
TW_EXCLUDE_APEX := true
TW_HAS_EDL_MODE := true

# Haptic
FIXED_HAPTICS := true

ifeq ($(FIXED_HAPTICS),true)
   TW_SUPPORT_INPUT_AIDL_HAPTICS := true
   TW_SUPPORT_INPUT_AIDL_HAPTICS_FQNAME := "IVibrator/vibratorfeature"
#  TW_SUPPORT_INPUT_AIDL_HAPTICS_FIX_OFF := true
else
   TW_NO_HAPTICS := true
endif

TW_USE_SERIALNO_PROPERTY_FOR_DEVICE_ID := true
TW_LOAD_VENDOR_MODULES := "xiaomi_touch.ko nt36532_touch.ko qti_battery_charger.ko"
TW_LOAD_VENDOR_MODULES_EXCLUDE_GKI := true
TW_CUSTOM_CPU_TEMP_PATH := "/sys/class/thermal/thermal_zone48/temp"
TW_BATTERY_SYSFS_WAIT_SECONDS := 6
