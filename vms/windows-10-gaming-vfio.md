# Verify

	sudo dmesg | rg -i -e DMAR -e IOMMU
	
# Get Devices

	iommu
	
Current list: 10de:1b02,10de:10ef,10ec:8125,1b73:1100

# Set in bootloader

	sudoedit /boot/loader/entries/*.conf
	# append vfio-pci.ids=10de:1b02,10de:10ef,10ec:8125,1b73:1100
	

# Add to mkinitcpio

	sudoedit /etc/mkinitcpio.conf
	# should go before nvidia drivers if there.
	#   MODULES=(... vfio_pci vfio vfio_iommu_type1 ...)
	# ensure modconf hook
	#   HOOKS=(... modconf ...)
	sudo mkinitcpio -p linux

# Make machine

* Use both win10 ISO and vfio so you can use vfio SCSI.

https://github.com/virtio-win/virtio-win-pkg-scripts/blob/master/README.md

* remove spice hardware
* change disk to virtio
* add PCI passthrough hardware
* hide kvm for nvidia
      <features>
        ...
        <kvm>
          <hidden state='on'/>
        </kvm>
        ...
      </features>
* Set boot mode to UEFI

* For nvidia: https://mathiashueber.com/fighting-error-43-nvidia-gpu-virtual-machine/

* after install, realtek drivers as well (on files usb)

* CPU to host passthrough
