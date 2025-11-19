# AnyKernel3 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() { '
do.devicecheck=1
do.modules=0
do.systemless=1
do.cleanup=1
do.cleanuponabort=0
device.name1=alioth
device.name2=aliothin
'; } # end properties

# shell variables
block=/dev/block/bootdevice/by-name/boot;
is_slot_device=1;
ramdisk_compression=auto;


## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. tools/ak3-core.sh;


## AnyKernel file attributes
# set permissions/ownership for included ramdisk files
set_perm_recursive 0 0 750 750 $ramdisk/*;

# Auto‑detect variant from zip name
case "$ZIPFILE" in
  *-5k*)      v=5k;;
  *z0kernel*) v=default;;
esac

# If none are detected (adb sideload), let the user pick
if [ -z "$v" ]; then
  set -- 5k default
  i=1; n=$#
  prev_option=""
  ui_print "Select DTBO variant:"
  while :; do
    eval "current_option=\${$i}"
    # Only print when the option changes
    if [ "$current_option" != "$prev_option" ]; then
      ui_print "> Option selected: $current_option  (Vol–=Next  Vol+=Select)"
      prev_option="$current_option"
    fi
    ev=$(getevent -lc1 2>/dev/null | tr -d '\r')
    case $ev in
      *KEY_VOLUMEDOWN*DOWN*)
        i=$(( i % n + 1 ))
        ;;
      *KEY_VOLUMEUP*DOWN*)
        v="$current_option"
        break
        ;;
    esac
    sleep 0.1
  done
fi

# Select default if still unset
[ -z "$v" ] && v=default

# Apply the right dtbo
ui_print " • Using $v DTBO"
if [ "$v" != default ]; then
  rm -f dtbo.img && mv "$v/dtbo.img" "dtbo.img"
fi

## AnyKernel install
dump_boot;

# Begin Ramdisk Changes

# migrate from /overlay to /overlay.d to enable SAR Magisk
if [ -d $ramdisk/overlay ]; then
  rm -rf $ramdisk/overlay;
fi;

write_boot;
## end install

## vendor_boot shell variables
block=/dev/block/bootdevice/by-name/vendor_boot;
is_slot_device=1;
ramdisk_compression=auto;
patch_vbmeta_flag=auto;

# reset for vendor_boot patching
reset_ak;

# vendor_boot install
dump_boot;

write_boot;
## end vendor_boot install
