
PRODUCT_COPY_FILES += \
    device/generic/goldfish/data/etc/permissions/privapp-permissions-goldfish.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/privapp-permissions-goldfish.xml \

PRODUCT_ENFORCE_ARTIFACT_PATH_REQUIREMENTS :=
MODULE_BUILD_FROM_SOURCE := true

PRODUCT_SDK_ADDON_NAME := custom
PRODUCT_SDK_ADDON_SYS_IMG_SOURCE_PROP := $(LOCAL_PATH)/source.properties
