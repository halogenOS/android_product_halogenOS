# Inherit mobile full common custom stuff
$(call inherit-product, $(CUSTOM_PRODUCT_DIR)/config/common_mobile_full.mk)

# Inherit tablet common custom stuff
$(call inherit-product, $(CUSTOM_PRODUCT_DIR)/config/tablet.mk)

$(call inherit-product, $(CUSTOM_PRODUCT_DIR)/config/wifionly.mk)
