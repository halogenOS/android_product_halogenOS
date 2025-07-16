# Allow vendor/extra to override any property by setting it first
$(call inherit-product-if-exists, vendor/extra/product.mk)

PRODUCT_BRAND ?= $(CUSTOM_PRODUCT)

ifeq ($(PRODUCT_GMS_CLIENTID_BASE),)
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.com.google.clientidbase=android-google
else
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.com.google.clientidbase=$(PRODUCT_GMS_CLIENTID_BASE)
endif

ifeq ($(PRODUCT_IS_ATV),true)
ifeq ($(PRODUCT_ATV_CLIENTID_BASE),)
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.oem.key1=ATV00100020
else
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.oem.key1=$(PRODUCT_ATV_CLIENTID_BASE)
endif
endif

ifeq ($(TARGET_BUILD_VARIANT),eng)
# Disable ADB authentication
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += ro.adb.secure=0
else
ifdef WITH_ADB_INSECURE
# Forcebly disable ADB authentication
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += ro.adb.secure=0
else
# Enable ADB authentication
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += ro.adb.secure=1
endif

# Disable extra StrictMode features on all non-engineering builds
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += persist.sys.strictmode.disable=true
endif

PRODUCT_SYSTEM_DEFAULT_PROPERTIES += persist.device_config.configuration.disable_rescue_party=true

# Enable Material Design 3 Expressive
PRODUCT_PRODUCT_PROPERTIES += \
    is_expressive_design_enabled=true

ifneq ($(strip $(AB_OTA_PARTITIONS) $(AB_OTA_POSTINSTALL_CONFIG)),)
ifneq ($(TARGET_BUILD_VARIANT),user)
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.ota.allow_downgrade=true
endif
endif

# custom broadcast actions whitelist
PRODUCT_COPY_FILES += \
    $(CUSTOM_PRODUCT_DIR)/config/permissions/custom-sysconfig.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/sysconfig/custom-sysconfig.xml

# custom-specific init rc file
PRODUCT_COPY_FILES += \
    $(CUSTOM_PRODUCT_DIR)/prebuilt/common/etc/init/init.custom-system_ext.rc:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/init/init.custom-system_ext.rc

# Enable SIP+VoIP on all targets
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.sip.voip.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/android.software.sip.voip.xml

# Enable wireless Xbox 360 controller support
PRODUCT_COPY_FILES += \
    frameworks/base/data/keyboards/Vendor_045e_Product_028e.kl:$(TARGET_COPY_OUT_PRODUCT)/usr/keylayout/Vendor_045e_Product_0719.kl

# Component overrides
PRODUCT_PACKAGES += \
    custom-component-overrides.xml

# Enforce privapp-permissions whitelist
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.control_privapp_permissions=enforce

# Do not include art debug targets
PRODUCT_ART_TARGET_INCLUDE_DEBUG_BUILD := false

# Strip the local variable table and the local variable type table to reduce
# the size of the system image. This has no bearing on stack traces, but will
# leave less information available via JDWP.
PRODUCT_MINIMIZE_JAVA_DEBUG_INFO := true

# Disable vendor restrictions
PRODUCT_RESTRICT_VENDOR_FILES := false

ifneq ($(TARGET_DISABLE_EPPE),true)
# Require all requested packages to exist
$(call enforce-product-packages-exist-internal,$(wildcard device/*/$(CUSTOM_BUILD)/$(TARGET_PRODUCT).mk),product_manifest.xml rild Calendar Launcher3 Launcher3Go Launcher3QuickStep Launcher3QuickStepGo android.hidl.memory@1.0-impl.vendor vndk_apex_snapshot_package)
endif

# Bootanimation
TARGET_SCREEN_WIDTH ?= 1080
TARGET_SCREEN_HEIGHT ?= 1920
PRODUCT_PACKAGES += \
    bootanimation.zip

ifeq ($(PRODUCT_IS_ATV),)
PRODUCT_PACKAGES += \
    ExactCalculator \
    Jelly
endif

PRODUCT_PACKAGES += \
    Updater
# Config
PRODUCT_PACKAGES += \
    SimpleDeviceConfig \
    SimpleSettingsConfig

# Extra tools
PRODUCT_PACKAGES += \
    bash \
    curl \
    getcap \
    htop \
    nano \
    setcap \
    vim

PRODUCT_PACKAGES += \
    nano_recovery

PRODUCT_ARTIFACT_PATH_REQUIREMENT_ALLOWED_LIST += \
    system/bin/curl \
    system/bin/getcap \
    system/bin/setcap

# FRP
PRODUCT_COPY_FILES += \
    $(CUSTOM_PRODUCT_DIR)/prebuilt/common/bin/wipe-frp.sh:$(TARGET_COPY_OUT_RECOVERY)/root/system/bin/wipe-frp

# rsync
PRODUCT_PACKAGES += \
    rsync

PRODUCT_COPY_FILES += \
    $(CUSTOM_PRODUCT_DIR)/prebuilt/common/etc/init/init.custom.rc:$(TARGET_COPY_OUT_PRODUCT)/etc/init/init.custom.rc

PRODUCT_COPY_FILES += \
    $(CUSTOM_PRODUCT_DIR)/prebuilt/common/etc/init/init.custom.rc:$(TARGET_COPY_OUT_PRODUCT)/etc/init/init.custom.rc

# These packages are excluded from user builds
PRODUCT_PACKAGES_DEBUG += \
    procmem

ifneq ($(TARGET_BUILD_VARIANT),user)
PRODUCT_ARTIFACT_PATH_REQUIREMENT_ALLOWED_LIST += \
    system/bin/procmem
endif

# Root
PRODUCT_PACKAGES += \
    adb_root

# SystemUI
PRODUCT_DEXPREOPT_SPEED_APPS += \
    CarSystemUI \
    SystemUI

PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    dalvik.vm.systemuicompilerfilter=speed


# Permissions
PRODUCT_COPY_FILES += \
    $(CUSTOM_PRODUCT_DIR)/config/permissions/privapp-permissions-custom.xml:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/permissions/privapp-permissions-custom.xml


ifeq ($(TARGET_BUILD_VARIANT),userdebug)
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    debug.sf.enable_transaction_tracing=false
endif

# SetupWizard
PRODUCT_PRODUCT_PROPERTIES += \
    setupwizard.theme=glif_v4 \
    setupwizard.feature.day_night_mode_enabled=true

PRODUCT_PACKAGES += \
    DocumentsUIOverlay \
    NetworkStackOverlay \
    PermissionControllerOverlay

# Translations
CUSTOM_LOCALES += \
    ast_ES \
    gd_GB \
    cy_GB \
    fur_IT

# Predictive back by default
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += persist.wm.debug.predictive_back_sysui_enable=1

# Disable Storage Manger by default
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += ro.storage_manager.enabled=false

PRODUCT_EXTRA_RECOVERY_KEYS += \
    $(CUSTOM_PRODUCT_DIR)/build/target/product/security/custom

-include $(CUSTOM_PRODUCT_DIR)-priv/keys/keys.mk
-include vendor/$(CUSTOM_PRODUCT)/private/keys/keys.mk

ifeq ($(PRODUCT_DEFAULT_AVB_KEY),)
PRODUCT_DEFAULT_AVB_KEY := external/avb/test/data/testkey_rsa4096.pem
else
$(shell echo Using AVB key $(PRODUCT_DEFAULT_AVB_KEY) >&2)
endif

$(call inherit-product, $(CUSTOM_PRODUCT_DIR)/config/apps.mk)
$(call inherit-product, $(CUSTOM_PRODUCT_DIR)/config/overlays.mk)

# Fonts
$(call inherit-product, external/custom-fonts/adwaita-sans/fonts.mk)
$(call inherit-product, external/google-fonts/lato/fonts.mk)
$(call inherit-product, external/google-fonts/rubik/fonts.mk)

# Fonts
PRODUCT_PACKAGES += \
    FontLatoOverlay \
    FontRubikOverlay

PRODUCT_PACKAGES += custom_fonts_customization_product

PRODUCT_RELEASE_CONFIG_MAPS += $(wildcard $(CUSTOM_PRODUCT_DIR)/release/release_config_map.mk)

$(call inherit-product, $(CUSTOM_PRODUCT_DIR)/config/branding.mk)

ifeq ($(RELEASE_PLATFORM_SECURITY_PATCH),$(VENDOR_SECURITY_PATCH))
$(shell echo "Note: Release platform security patch is the same as vendor security patch ($(RELEASE_PLATFORM_SECURITY_PATCH) == $(VENDOR_SECURITY_PATCH))" >&2)
endif
