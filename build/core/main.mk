
ifeq ($(CUSTOM_PRODUCT_ANNOUNCE),true)
$(shell echo "$(CUSTOM_PRODUCT) product activated, dir: $(CUSTOM_PRODUCT_DIR)" >&2)
endif

include $(CUSTOM_PRODUCT_DIR)/config/branding.mk
