# Inherit mobile full common custom stuff
$(call inherit-product, $(CUSTOM_PRODUCT_DIR)/config/common_mobile_full.mk)

# Enable support of one-handed mode
PRODUCT_PRODUCT_PROPERTIES += \
    ro.support_one_handed_mode?=true

$(call inherit-product, $(CUSTOM_PRODUCT_DIR)/config/telephony.mk)
