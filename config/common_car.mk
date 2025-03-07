# Inherit common stuff
$(call inherit-product, $(CUSTOM_PRODUCT_DIR)/config/common.mk)

# Inherit Lineage car device tree
$(call inherit-product, device/lineage/car/lineage_car.mk)
