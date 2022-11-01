include $(CUSTOM_PRODUCT_DIR)/config/BoardConfigSoong.mk
include $(CUSTOM_PRODUCT_DIR)/config/BoardConfigQcom.mk
include $(CUSTOM_PRODUCT_DIR)/build/core/pathmap.mk


#DEVICE_PACKAGE_OVERLAYS += $(CUSTOM_PRODUCT_DIR)/overlay

# Styles & wallpapers
PRODUCT_COPY_FILES += \
    $(CUSTOM_PRODUCT_DIR)/config/permissions/privapp_whitelist_com.android.wallpaper.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/privapp_whitelist_com.android.wallpaper.xml \
    $(CUSTOM_PRODUCT_DIR)/config/permissions/default_com.android.wallpaper.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/default-permissions/default_com.android.wallpaper.xml


