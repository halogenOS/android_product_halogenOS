# Inherit full common custom stuff
$(call inherit-product, $(CUSTOM_PRODUCT_DIR)/config/common_full.mk)

# Required packages
PRODUCT_PACKAGES += \
    androidx.window.extensions \
    LatinIME

# Include Lineage LatinIME dictionaries
PRODUCT_PACKAGE_OVERLAYS += $(CUSTOM_PRODUCT_DIR)/overlay/dictionaries
PRODUCT_ENFORCE_RRO_EXCLUDED_OVERLAYS += $(CUSTOM_PRODUCT_DIR)/overlay/dictionaries
