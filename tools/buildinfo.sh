
CUSTOM_BUILD_DATE_UTC=$(date -u +"%Y-%m-%d %H:%M:%S")
CUSTOM_BUILD_DATE=$(date -u +"%Y%m%d-%H%M%S")
CUSTOM_VERSION="${CUSTOM_PRODUCT_NAME}_${CUSTOM_DEVICE}-${CUSTOM_PLATFORM_VERSION}-${CUSTOM_BUILD_DATE}-${CUSTOM_BUILD_TYPE}"
CUSTOM_DISPLAY_VERSION="${CUSTOM_PLATFORM_VERSION}-${CUSTOM_BUILD_DATE}-${CUSTOM_BUILD_TYPE}"



echo "ro.custom.device=$CUSTOM_DEVICE"
echo "ro.custom.build.version.sp=$PLATFORM_SECURITY_PATCH"
echo "ro.custom.build.device.maintainer=$DEVICE_MAINTAINER"
echo "ro.custom.version=$CUSTOM_VERSION"
echo "ro.custom.build.version=$CUSTOM_PLATFORM_VERSION"
echo "ro.custom.display.version=$CUSTOM_DISPLAY_VERSION"
echo "ro.custom.build_date=$CUSTOM_BUILD_DATE"
echo "ro.custom.build_date_utc=$CUSTOM_BUILD_DATE_UTC"
echo "ro.custom.build_type=$CUSTOM_BUILD_TYPE"