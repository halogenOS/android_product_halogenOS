# Set custom specific identifier for Android Go enabled products
PRODUCT_TYPE := go

# Inherit mini common custom stuff
$(call inherit-product, $(CUSTOM_PRODUCT_DIR)/config/common_mini_phone.mk)
