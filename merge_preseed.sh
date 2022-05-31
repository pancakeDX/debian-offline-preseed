#!/bin/bash 

set -e 

RAW_DEBIAN_ISO='./iso_source/debian-11.3.0-amd64-offline.iso'

WORKDIR='./workdir'

PRESEED_FILE='./preseed.cfg'
PRESEED_ISO='./iso_destination/debian-11.3.0-amd64-offline-preseeded.iso'

# Prepare working folder
if [ -d "$WORKDIR" ]; then
    chmod +w -R $WORKDIR
    rm -rf $WORKDIR
fi

# Extract image
mkdir -p $WORKDIR
bsdtar -C "$WORKDIR/" -xf "$RAW_DEBIAN_ISO"
chmod +w -R $WORKDIR

# Inject preseed file
gunzip $WORKDIR/install.amd/initrd.gz
echo $PRESEED_FILE | cpio -H newc -o -A -F $WORKDIR/install.amd/initrd &> /dev/null
gzip $WORKDIR/install.amd/initrd

# Update md5sum
pushd $WORKDIR &> /dev/null
find . -type f -exec md5sum "{}" \; > md5sum.txt
popd &> /dev/null

# Create ISO
chmod -R -w $WORKDIR

dd if=$RAW_DEBIAN_ISO bs=1 count=432 of=isohdpfx.bin

xorriso -as mkisofs -o $PRESEED_ISO \
-isohybrid-mbr isohdpfx.bin \
-c isolinux/boot.cat -b isolinux/isolinux.bin -no-emul-boot -boot-load-size 4 -boot-info-table \
-eltorito-alt-boot -e boot/grub/efi.img -no-emul-boot -isohybrid-gpt-basdat \
$WORKDIR

echo "---> Preseed config $PRESEED_FILE has been successfully merged into image $PRESEED_ISO"

# Clean up
chmod -R +w $WORKDIR
rm -rf $WORKDIR
rm -f isohdpfx.bin