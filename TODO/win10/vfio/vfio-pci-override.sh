#!/bin/sh

# Override the 3rd NVMe drive.
# 0000:23:00.0 - /dev/disk/by-id/nvme-Sabrent_Rocket_4.0_1TB_03F10797044452198275
DEVS="0000:23:00.0"

if [ ! -z "$(ls -A /sys/class/iommu)" ]; then
    for DEV in $DEVS; do
        echo "vfio-pci" > /sys/bus/pci/devices/$DEV/driver_override
    done
fi
