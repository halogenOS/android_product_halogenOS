#
# Copyright (C) 2016 The CyanogenMod Project
#               2017-2019 The LineageOS Project
#               2019-2022 The halogenOS Project
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
#

TARGET_GENERATED_BOOTANIMATION := $(TARGET_OUT_INTERMEDIATES)/BOOTANIMATION/bootanimation.zip
$(TARGET_GENERATED_BOOTANIMATION): INTERMEDIATES := $(call intermediates-dir-for,BOOTANIMATION,bootanimation)
$(TARGET_GENERATED_BOOTANIMATION): $(SOONG_ZIP) $(shell find $(CUSTOM_PRODUCT_DIR)/bootanimation/ -type f)
	@echo "Building bootanimation.zip"
	@rm -rf $(dir $@) $(INTERMEDIATES)
	@mkdir -p $(dir $@) $(INTERMEDIATES)
	$(hide) cp -R $(CUSTOM_PRODUCT_DIR)/bootanimation/frames/. $(INTERMEDIATES)
	$(hide) if [ $(TARGET_SCREEN_HEIGHT) -lt $(TARGET_SCREEN_WIDTH) ]; then \
	    IMAGEWIDTH=$(TARGET_SCREEN_WIDTH); \
	else \
	    IMAGEHEIGHT=$(TARGET_SCREEN_HEIGHT); \
	fi; \
	MOGRIFY="prebuilts/tools-lineage/${HOST_OS}-x86/bin/mogrify"; \
	RESOLUTION="$$IMAGEWIDTH"x"$$IMAGEHEIGHT" ; \
	find $(INTERMEDIATES) -type f -iname '*.png' | xargs -n 1 -P 4 $$MOGRIFY -resize $$RESOLUTION -colors 250; \
	FIRST_PNG_FILE="$$(find $(INTERMEDIATES) -type f -iname '*.png' | head -n1)"; \
	SCALE_WIDTH="$$($$MOGRIFY -print %w $$FIRST_PNG_FILE)"; \
	SCALE_HEIGHT="$$($$MOGRIFY -print %h $$FIRST_PNG_FILE)"; \
	echo "$$SCALE_WIDTH $$SCALE_HEIGHT $$(cat $(CUSTOM_PRODUCT_DIR)/bootanimation/fps.txt)" > $(INTERMEDIATES)/desc.txt; \
	cat $(CUSTOM_PRODUCT_DIR)/bootanimation/desc.txt >> $(INTERMEDIATES)/desc.txt
	$(hide) $(SOONG_ZIP) -L 0 -o $@ -C $(INTERMEDIATES) -D $(INTERMEDIATES)

ifeq ($(TARGET_BOOTANIMATION),)
    TARGET_BOOTANIMATION := $(TARGET_GENERATED_BOOTANIMATION)
endif

include $(CLEAR_VARS)
LOCAL_MODULE := bootanimation.zip
LOCAL_MODULE_CLASS := ETC
LOCAL_MODULE_PATH := $(TARGET_OUT_PRODUCT)/media

include $(BUILD_SYSTEM)/base_rules.mk

$(LOCAL_BUILT_MODULE): $(TARGET_BOOTANIMATION)
	@cp $(TARGET_BOOTANIMATION) $@

include $(CLEAR_VARS)

BOOTANIMATION_SYMLINK := $(TARGET_OUT_PRODUCT)/media/bootanimation-dark.zip
$(BOOTANIMATION_SYMLINK): $(LOCAL_INSTALLED_MODULE)
	@mkdir -p $(dir $@)
	$(hide) ln -sf bootanimation.zip $@

ALL_DEFAULT_INSTALLED_MODULES += $(BOOTANIMATION_SYMLINK)
