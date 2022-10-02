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

PRODUCT_COPY_FILES += \
    device/generic/goldfish/data/etc/permissions/privapp-permissions-goldfish.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/privapp-permissions-goldfish.xml \

PRODUCT_ENFORCE_ARTIFACT_PATH_REQUIREMENTS :=
MODULE_BUILD_FROM_SOURCE := true

PRODUCT_SDK_ADDON_NAME := custom
PRODUCT_SDK_ADDON_SYS_IMG_SOURCE_PROP := $(LOCAL_PATH)/source.properties
