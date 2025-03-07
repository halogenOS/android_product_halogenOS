# Inherit common custom stuff
$(call inherit-product, $(CUSTOM_PRODUCT_DIR)/config/common.mk)

# Include AOSP audio files
$(call inherit-product-if-exists, frameworks/base/data/sounds/AudioTv.mk)

# Inherit Lineage atv device tree
$(call inherit-product, device/lineage/atv/lineage_atv.mk)

# AOSP packages
PRODUCT_PACKAGES += \
    LeanbackIME

# Lineage packages
PRODUCT_PACKAGES += \
    Catapult

PRODUCT_PACKAGE_OVERLAYS += $(CUSTOM_PRODUCT_DIR)/overlay/tv
