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

PRODUCT_MINIMIZE_JAVA_DEBUG_INFO := true
PRODUCT_ART_TARGET_INCLUDE_DEBUG_BUILD := false

PRODUCT_SOONG_NAMESPACES += $(CUSTOM_PRODUCT_DIR)/config

PRODUCT_PACKAGES += \
    ThemePicker \
    ThemeStub

PRODUCT_PACKAGES += \
    aosp-sysconfig.xml
