#
# Copyright (C) 2026 The Android Open Source Project
# Copyright (C) 2026 SebaUbuntu's TWRP device tree generator
#
# SPDX-License-Identifier: Apache-2.0
#

LOCAL_PATH := $(call my-dir)

ifneq ($(filter uke% twrp_uke% fox_uke%,$(TARGET_DEVICE) $(TARGET_PRODUCT)),)
include $(call all-subdir-makefiles,$(LOCAL_PATH))

# Recovery root destination directory
RECOVERY_ROOT_DIR := $(or $(TARGET_RECOVERY_ROOT_OUT),$(PRODUCT_OUT)/recovery/root,out/target/product/uke/recovery/root)

# 1. Immediate parse-time staging of all twres assets
$(shell mkdir -p $(RECOVERY_ROOT_DIR)/twres && cp -rf $(LOCAL_PATH)/recovery/root/twres/* $(RECOVERY_ROOT_DIR)/twres/ 2>/dev/null)
$(shell mkdir -p out/target/product/uke/recovery/root/twres && cp -rf device/xiaomi/uke/recovery/root/twres/* out/target/product/uke/recovery/root/twres/ 2>/dev/null)

# 2. Prebuilt modules for twres XMLs (registered via TARGET_RECOVERY_DEVICE_MODULES)
include $(CLEAR_VARS)
LOCAL_MODULE := twres-splash
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := ETC
LOCAL_MODULE_PATH := $(RECOVERY_ROOT_DIR)/twres
LOCAL_SRC_FILES := recovery/root/twres/splash.xml
LOCAL_MODULE_STEM := splash.xml
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE := twres-ui
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := ETC
LOCAL_MODULE_PATH := $(RECOVERY_ROOT_DIR)/twres
LOCAL_SRC_FILES := recovery/root/twres/ui.xml
LOCAL_MODULE_STEM := ui.xml
include $(BUILD_PREBUILT)

# 3. Explicit Ninja dependency: ensure twres files exist before recovery executable post-install runs
$(RECOVERY_ROOT_DIR)/system/bin/recovery: | $(RECOVERY_ROOT_DIR)/twres/splash.xml $(RECOVERY_ROOT_DIR)/twres/ui.xml
out/target/product/uke/recovery/root/system/bin/recovery: | out/target/product/uke/recovery/root/twres/splash.xml out/target/product/uke/recovery/root/twres/ui.xml

endif
