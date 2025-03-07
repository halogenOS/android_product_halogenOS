
PRODUCT_PACKAGES += \
    CustomDocumentsUIOverlay \
    CustomFrameworkOverlay \
    CustomLauncher3Overlay \
    CustomSettingsOverlay \
    CustomSettingsProviderOverlay \
    CustomSetupDesignOverlay \
    CustomSystemUIOverlay \
    CustomThemePickerOverlay \
    CustomVoicemailOverlay \
    CustomNetworkStackOverlay

PRODUCT_PACKAGES += \
    CustomBlackTheme \
    CustomThemesStub

PRODUCT_COPY_FILES += \
    $(CUSTOM_PRODUCT_DIR)/config/overlay/config-product.xml:$(TARGET_COPY_OUT_PRODUCT)/overlay/config/config.xml

