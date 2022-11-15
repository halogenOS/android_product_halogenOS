
this_product_name="halogenOS"

export CUSTOM_PRODUCT="${CUSTOM_PRODUCT:=$this_product_name}"

if [[ "$CUSTOM_PRODUCT" == "$this_product_name" ]]; then
    export CUSTOM_PRODUCT_DIR="product/$this_product_name"
    export CUSTOM_PRODUCT_NAME="$this_product_name"

    XOS_TOOLS_SCRIPT="external/xos/xostools/xostools.sh"
    if [ -f "$XOS_TOOLS_SCRIPT" ]; then
        source "$XOS_TOOLS_SCRIPT"
    fi

    export TOP="$(pwd)"

    export CUSTOM_PRODUCT_DIR="$CUSTOM_PRODUCT_DIR"
    # Please use CUSTOM_PRODUCT_DIR instead of CUSTOM_VENDOR_DIR
    # We are not a vendor, but a product. We don't sell products, we are the product.
    # See https://source.android.com/docs/core/architecture/bootloader/partitions/odm-partitions#maintain-ABIs
    export CUSTOM_VENDOR_DIR="$CUSTOM_PRODUCT_DIR"

    export ROM_VERSION="$( (xmlstarlet sel -t -v "/manifest/remote[@name='XOS']/@revision" "$TOP/.repo/manifests/snippets/XOS.xml" | sed -e 's/refs\/heads\///') || \
                            (repo branch | grep '^\*' | awk '{ print $2 }') )"
fi

breakfast() {
    if [ -z "$1" ]; then
        echo "Please specify a device"
        return 1
    fi
    PWD=$(pwd)
    ${CUSTOM_PRODUCT_DIR}/build/tools/roomservice.py $1
    cd "$PWD"
}
