# SPDX-FileCopyrightText: 2024 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0

$(call inherit-product, device/google/cuttlefish/vsoc_x86_64_only/auto/aosp_cf.mk)

include $(CUSTOM_PRODUCT_DIR)/build/target/product/aosp_generic_car_target.mk

TARGET_NO_KERNEL_OVERRIDE := true

# Enable mainline checking
PRODUCT_ENFORCE_ARTIFACT_PATH_REQUIREMENTS := relaxed

# Overrides
PRODUCT_NAME := aosp_cf_car_x86_64
PRODUCT_MODEL := Custom Cuttlefish car built for x86_64
