# Inherit mini common custom stuff
$(call inherit-product, $(CUSTOM_PRODUCT_DIR)/config/common_mini.mk)

# Required packages
PRODUCT_PACKAGES += \
    androidx.window.extensions \
    LatinIME
