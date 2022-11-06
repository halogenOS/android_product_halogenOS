# Inherit full common custom stuff
$(call inherit-product, $(CUSTOM_PRODUCT_DIR)/config/common_full.mk)

# Required packages
PRODUCT_PACKAGES += \
    LatinIME

# Include Lineage LatinIME dictionaries
PRODUCT_PACKAGE_OVERLAYS += $(CUSTOM_PRODUCT_DIR)/overlay/dictionaries
PRODUCT_ENFORCE_RRO_EXCLUDED_OVERLAYS += $(CUSTOM_PRODUCT_DIR)/overlay/dictionaries

# Enable support of one-handed mode
PRODUCT_PRODUCT_PROPERTIES += \
    ro.support_one_handed_mode=true

$(call inherit-product, $(CUSTOM_PRODUCT_DIR)/config/telephony.mk)
