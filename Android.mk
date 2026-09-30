#
# Copyright (C) 2026 The Android Open Source Project
# Copyright (C) 2026 SebaUbuntu's TWRP device tree generator
#
# SPDX-License-Identifier: Apache-2.0
#

LOCAL_PATH := $(call my-dir)

ifneq ($(filter uke twrp_uke,$(TARGET_DEVICE)),)

# Compatibility shims for deprecated -ndk_platform AIDL dependencies in TWRP
define add-ndk-platform-shim
include $$(CLEAR_VARS)
LOCAL_MODULE := $(1)
LOCAL_MODULE_TAGS := optional
LOCAL_SRC_FILES := recovery_shim.c
LOCAL_MODULE_CLASS := SHARED_LIBRARIES
LOCAL_MODULE_PATH := $$(TARGET_RECOVERY_ROOT_OUT)/system/lib64
include $$(BUILD_SHARED_LIBRARY)
endef

$(eval $(call add-ndk-platform-shim,android.security.apc-ndk_platform))
$(eval $(call add-ndk-platform-shim,android.security.authorization-ndk_platform))
$(eval $(call add-ndk-platform-shim,android.security.maintenance-ndk_platform))
$(eval $(call add-ndk-platform-shim,android.system.keystore2-V1-ndk_platform))

include $(call all-subdir-makefiles,$(LOCAL_PATH))
endif
