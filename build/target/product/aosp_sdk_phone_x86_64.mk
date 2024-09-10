# Copyright (C) 2021 The LineageOS Project
# Copyright (C) 2022 The halogenOS Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

include $(CUSTOM_PRODUCT_DIR)/build/target/product/base/aosp_sdk_phone.mk

# Overrides
PRODUCT_MODEL := $(CUSTOM_PRODUCT_NAME) for x86_64

# Workaround "data" dir issue (https://stackoverflow.com/questions/73918125/how-to-fix-the-sdk-addon-data-copy-build-error)
LOCAL_DATA_OUT_DIR := out/target/product/vsoc_x86_64/data
$(shell mkdir -p $(LOCAL_DATA_OUT_DIR))
$(shell echo "Workaround of data dir issue active, created $(LOCAL_DATA_OUT_DIR)" >&2)
