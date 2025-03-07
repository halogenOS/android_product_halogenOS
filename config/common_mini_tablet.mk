# Inherit mobile mini common custom stuff
$(call inherit-product, $(CUSTOM_PRODUCT_DIR)/config/common_mobile_mini.mk)

# Inherit tablet common custom stuff
$(call inherit-product, $(CUSTOM_PRODUCT_DIR)/config/tablet.mk)

$(call inherit-product, $(CUSTOM_PRODUCT_DIR)/config/telephony.mk)
