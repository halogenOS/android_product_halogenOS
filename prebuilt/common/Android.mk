LOCAL_PATH := $(call my-dir)

################################
# Copies the APN list file into $(TARGET_COPY_OUT_PRODUCT)/etc for the product as apns-conf.xml.
# In the case where $(CUSTOM_APNS_FILE) is defined, the content of $(CUSTOM_APNS_FILE)
# is added or replaced to the $(DEFAULT_APNS_FILE).
include $(CLEAR_VARS)

LOCAL_MODULE := apns-conf.xml
LOCAL_MODULE_CLASS := ETC

DEFAULT_APNS_FILE := $(CUSTOM_PRODUCT_DIR)/prebuilt/common/etc/apns-conf.xml
FINAL_APNS_FILE := $(DEFAULT_APNS_FILE)

LOCAL_PREBUILT_MODULE_FILE := $(FINAL_APNS_FILE)

LOCAL_PRODUCT_MODULE := true

include $(BUILD_PREBUILT)
