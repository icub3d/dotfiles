#!/usr/bin/fish

mkdir -p /usr/bin /etc/initcpio/install /etc/initcpio/hooks

cp etc-initcpio-hooks-vfio /etc/initcpio/hooks/vfio
cp etc-initcpio-install-vfio /etc/initcpio/install/vfio
cp vfio-pci-override.sh /usr/bin

echo 'update mkinitcpio.conf as described at https://wiki.archlinux.org/index.php/PCI_passthrough_via_OVMF#Script_installation'
