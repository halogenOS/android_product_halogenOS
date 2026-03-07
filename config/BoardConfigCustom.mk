include $(CUSTOM_PRODUCT_DIR)/config/BoardConfigKernel.mk

ifeq ($(BOARD_USES_QCOM_HARDWARE),true)
include hardware/qcom-caf/common/BoardConfigQcom.mk
endif

include $(CUSTOM_PRODUCT_DIR)/config/BoardConfigSoong.mk

# Custom SELinux policy
include device/custom/sepolicy/common/sepolicy.mk
