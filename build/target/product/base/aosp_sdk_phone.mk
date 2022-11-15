# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2022 The halogenOS Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include $(CUSTOM_PRODUCT_DIR)/config/common_full_phone.mk

PRODUCT_ENFORCE_ARTIFACT_PATH_REQUIREMENTS := relaxed
MODULE_BUILD_FROM_SOURCE := true

BUILD_EMULATOR := true

PRODUCT_SDK_ADDON_NAME := custom
PRODUCT_SDK_ADDON_SYS_IMG_SOURCE_PROP := $(CUSTOM_PRODUCT_DIR)/build/target/product/base/source.properties

# This is needed for INTERNAL_SDK_HOST_OS_NAME
ifeq ($(HOST_ARCH),x86_64)
SDK_HOST_ARCH := x86
else
SDK_HOST_ARCH := $(REAL_HOST_ARCH)
endif

# The Makefile appears to have a bug where this is only
# set when building the 'sdk' target so it would not be
# set for the 'sdk_addon' target. Specifying the 'sdk' target
# disallows specifying any other target in addition so this
# seems to be the right way to handle this situation.
INTERNAL_SDK_HOST_OS_NAME := linux-$(SDK_HOST_ARCH)
