
CUSTOM_DEVICE := $(TARGET_DEVICE)

CUSTOM_BUILD_TYPE ?= UNOFFICIAL

ifeq ($(CUSTOM_SKIP_BUILD_DATE),)
CUSTOM_BUILD_DATE_UTC := $(shell date -u +"%Y-%m-%d %H:%M:%S")
CUSTOM_BUILD_DATE := $(shell date -u +"%Y%m%d-%H%M%S")
else
CUSTOM_BUILD_DATE_UTC := 0000-00-00 00:00:00
CUSTOM_BUILD_DATE := 00000000-000000
endif

CUSTOM_PLATFORM_VERSION := 15.0

CUSTOM_VERSION := $(CUSTOM_PRODUCT_NAME)_$(CUSTOM_DEVICE)-$(CUSTOM_PLATFORM_VERSION)-$(CUSTOM_BUILD_DATE)-$(CUSTOM_BUILD_TYPE)

CUSTOM_DISPLAY_VERSION := $(CUSTOM_PLATFORM_VERSION)-$(CUSTOM_BUILD_DATE)-$(CUSTOM_BUILD_TYPE)

# Build fingerprint
ifeq ($(BUILD_FINGERPRINT),)
BUILD_NUMBER_CUSTOM := $(shell date -u +%H%M)
BUILD_FINGERPRINT := $(PRODUCT_BRAND)/$(CUSTOM_DEVICE)/$(CUSTOM_DEVICE):$(PLATFORM_VERSION)/$(BUILD_ID)/$(BUILD_NUMBER_CUSTOM):$(TARGET_BUILD_VARIANT)/$(BUILD_SIGNATURE_KEYS)
endif
ADDITIONAL_SYSTEM_PROPERTIES += \
    ro.build.fingerprint=$(BUILD_FINGERPRINT) \
    ro.custom.version=$(CUSTOM_VERSION) \
    ro.custom.build.version=$(CUSTOM_PLATFORM_VERSION) \
    ro.custom.display.version=$(CUSTOM_DISPLAY_VERSION) \
    ro.custom.build_date=$(CUSTOM_BUILD_DATE) \
    ro.custom.build_date_utc=$(CUSTOM_BUILD_DATE_UTC) \
    ro.custom.build_type=$(CUSTOM_BUILD_TYPE)
