# Inherit common custom stuff
$(call inherit-product, $(CUSTOM_PRODUCT_DIR)/config/common_mobile.mk)

PRODUCT_SIZE := full

# Apps
PRODUCT_PACKAGES += \
    Camelot \
    Etar
#     Profiles \
#     Recorder \
#     Twelve

ifneq ($(PRODUCT_NO_CAMERA),true)
# PRODUCT_PACKAGES += \
#     Aperture
endif

ifneq ($(TARGET_EXCLUDES_AUDIOFX),true)
# PRODUCT_PACKAGES += \
#     AudioFX
endif

# Extra cmdline tools
PRODUCT_PACKAGES += \
    zstd
#     unrar \

# Include custom LatinIME dictionaries
PRODUCT_PACKAGE_OVERLAYS += $(CUSTOM_PRODUCT_DIR)/overlay/dictionaries
PRODUCT_ENFORCE_RRO_EXCLUDED_OVERLAYS += $(CUSTOM_PRODUCT_DIR)/overlay/dictionaries
