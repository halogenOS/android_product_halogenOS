
CUSTOM_DEVICE := $(TARGET_DEVICE)

CUSTOM_BUILD_TYPE ?= UNOFFICIAL

CUSTOM_BUILD_DATE_UTC := $(shell date -u +"%Y-%m-%d %H:%M:%S")
CUSTOM_BUILD_DATE := $(shell date -u +"%Y%m%d-%H%M%S")

CUSTOM_PLATFORM_VERSION := 13.0

CUSTOM_VERSION := $(CUSTOM_PRODUCT_NAME)_$(CUSTOM_DEVICE)-$(CUSTOM_PLATFORM_VERSION)-$(CUSTOM_BUILD_DATE)-$(CUSTOM_BUILD_TYPE)

# Build fingerprint
ifeq ($(BUILD_FINGERPRINT),)
BUILD_NUMBER_CUSTOM := $(shell date -u +%H%M)
BUILD_FINGERPRINT := $(PRODUCT_BRAND)/$(CUSTOM_DEVICE)/$(CUSTOM_DEVICE):$(PLATFORM_VERSION)/$(BUILD_ID)/$(BUILD_NUMBER_CUSTOM):$(TARGET_BUILD_VARIANT)/$(BUILD_SIGNATURE_KEYS)
endif
ADDITIONAL_SYSTEM_PROPERTIES += \
    ro.build.fingerprint=$(BUILD_FINGERPRINT)

ADDITIONAL_SYSTEM_PROPERTIES += \
    ro.custom.version=$(CUSTOM_VERSION) \
    ro.custom.build.version=$(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR) \
    ro.custom.display.version=$(CUSTOM_DISPLAY_VERSION) \
    ro.custom.build_date=$(CUSTOM_BUILD_DATE) \
    ro.custom.build_date_utc=$(CUSTOM_BUILD_DATE_UTC) \
    ro.custom.build_type=$(CUSTOM_BUILD_TYPE)