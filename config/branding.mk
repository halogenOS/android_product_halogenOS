
CUSTOM_BUILD_TYPE ?= UNOFFICIAL

CUSTOM_DEVICE := $(shell echo "$(TARGET_PRODUCT)" | cut -d '_' -f2-)

# Build date is injected post-build by sign_build() to keep builds
# reproducible and avoid unnecessary rebuilds when only the timestamp
# changes.  The placeholder is replaced with the real date during signing.
CUSTOM_BUILD_DATE_PLACEHOLDER := 00000000-000000

CUSTOM_PLATFORM_VERSION := $(shell echo $(ROM_VERSION) | cut -d '-' -f2)

CUSTOM_VERSION := $(CUSTOM_PRODUCT_NAME)_$(CUSTOM_DEVICE)-$(CUSTOM_PLATFORM_VERSION)-$(CUSTOM_BUILD_DATE_PLACEHOLDER)-$(CUSTOM_BUILD_TYPE)

CUSTOM_DISPLAY_VERSION := $(CUSTOM_PLATFORM_VERSION)

# Build fingerprint — uses a fixed build number for reproducibility.
# The actual timestamp is injected post-build alongside the date.
ifeq ($(BUILD_FINGERPRINT),)
BUILD_FINGERPRINT := $(PRODUCT_BRAND)/$(CUSTOM_DEVICE)/$(CUSTOM_DEVICE):$(PLATFORM_VERSION)/$(BUILD_ID)/0000:$(TARGET_BUILD_VARIANT)/$(BUILD_SIGNATURE_KEYS)
endif

define base64urlencode
$(shell perl -e 'use MIME::Base64 qw(encode_base64url); print encode_base64url(@ARGV[0])' "$(subst ",\",$(1))")
endef

ifdef RELEASE_PLATFORM_SECURITY_PATCH_OVERRIDE
  ifeq ($(shell [[ $(RELEASE_PLATFORM_SECURITY_PATCH) > $(RELEASE_PLATFORM_SECURITY_PATCH_OVERRIDE) ]] && echo -n 1),1)
    CUSTOM_PLATFORM_SECURITY_PATCH := $(RELEASE_PLATFORM_SECURITY_PATCH)
  else
    CUSTOM_PLATFORM_SECURITY_PATCH := $(RELEASE_PLATFORM_SECURITY_PATCH_OVERRIDE)
  endif
else
CUSTOM_PLATFORM_SECURITY_PATCH := $(RELEASE_PLATFORM_SECURITY_PATCH)
endif

PRODUCT_PRODUCT_PROPERTIES += \
    ro.custom.build.device.maintainer=$(call base64urlencode,$(RELEASE_DEVICE_MAINTAINERS)) \
    ro.custom.build.version.sp=$(CUSTOM_PLATFORM_SECURITY_PATCH)  \
    ro.custom.version=$(CUSTOM_VERSION) \
    ro.custom.build.version=$(CUSTOM_PLATFORM_VERSION) \
    ro.custom.display.version=$(CUSTOM_DISPLAY_VERSION) \
    ro.custom.build_type=$(CUSTOM_BUILD_TYPE) \
