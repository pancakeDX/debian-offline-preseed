#!/bin/bash 

set -e 

function cleanup() {
        trap - SIGINT SIGTERM ERR EXIT
        if [ -n "${WORKDIR+x}" ]; then
                rm -rf "$WORKDIR"
                rm -f isohdpfx.bin
                log "🚽 Deleted temporary working directory $WORKDIR"
        fi
}

function log() {
        echo >&2 -e "[$(date +"%Y-%m-%d %H:%M:%S")] ${1-}"
}

function die() {
        local msg=$1
        local code=${2-1} # Bash parameter expansion - default exit status 1. See https://wiki.bash-hackers.org/syntax/pe#use_a_default_value
        log "$msg"
        exit "$code"
}

trap cleanup SIGINT SIGTERM ERR EXIT

RAW_DEBIAN_ISO='./iso_source/debian-11.3.0-amd64-netinst.iso'

WORKDIR=$(mktemp -d)

PRESEED_FILE='./preseed.cfg'
PRESEED_ISO='./iso_destination/debian-11.3.0-amd64-offline-preseeded.iso'

# Prepare working folder
if [[ ! "$WORKDIR" || ! -d "$WORKDIR" ]]; then
        die "💥 Could not create temporary working directory."
else
        log "📁 Created temporary working directory $WORKDIR"
fi

# Extract image
log "🔧 Extracting ISO image..."
xorriso -osirrox on -indev "${RAW_DEBIAN_ISO}" -extract / "$WORKDIR" &>/dev/null
chmod +w -R $WORKDIR
log "👍 Extracted to $WORKDIR"

# Copy custom files
log "🧩 Adding custom file..."
rsync -av --exclude='.gitignore' custom_files/* $WORKDIR/custom_files/ &> /dev/null
log "👍 Added custom file..."

# Inject preseed file
log "🧩 Adding preseed file..."
gunzip $WORKDIR/install.amd/initrd.gz
echo $PRESEED_FILE | cpio -H newc -o -A -F $WORKDIR/install.amd/initrd &> /dev/null
gzip $WORKDIR/install.amd/initrd
log "👍 Added preseed file..."

# Update md5sum
log "🧩 Updating md5sum..."
pushd $WORKDIR &> /dev/null
find . -type f -exec md5sum "{}" \; > md5sum.txt
popd &> /dev/null
log "👍 Updated md5sum..."

# Create ISO
log "📦 Repackaging extracted files into an ISO image..."

dd if=$RAW_DEBIAN_ISO bs=1 count=432 of=isohdpfx.bin &>/dev/null

xorriso -as mkisofs -o $PRESEED_ISO \
-isohybrid-mbr isohdpfx.bin \
-c isolinux/boot.cat -b isolinux/isolinux.bin -no-emul-boot -boot-load-size 4 -boot-info-table \
-eltorito-alt-boot -e boot/grub/efi.img -no-emul-boot -isohybrid-gpt-basdat \
$WORKDIR &>/dev/null

log "👍 Repackaged into ${PRESEED_ISO}"

die "✅ Completed." 0
