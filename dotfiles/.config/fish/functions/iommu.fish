function iommu
    for g in /sys/kernel/iommu_groups/*
        set GROUP_ID (basename $g)
        echo "IOMMU Group $GROUP_ID:"
        for d in $g/devices/*
            set DEVICE_ID (basename $d)
            echo -e "\t" (lspci -nns $DEVICE_ID)
        end
    end
end