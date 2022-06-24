function download-arch-iso
	set TO $argv[1]
	# Get the latest
	set ISO (http "https://mirrors.xtom.com/archlinux/iso/latest/" | rg -o 'archlinux-[.0-9]+-x86_64.iso' | sort | uniq)

	# Download ISO 
	http "https://mirrors.xtom.com/archlinux/iso/latest/$ISO" > "$TO/archlinux-x86_64.iso"

	# Download sig from Archlinux site.
	set VERSION (echo $ISO | rg -o '[.0-9]{10}')
	http "https://www.archlinux.org/iso/$VERSION/archlinux-$VERSION-x86_64.iso.sig" > "$TO/archlinux-x86_64.iso.sig"

	# Verify
	if not gpg -q --keyserver-options auto-key-retrieve --verify "$TO/archlinux-x86_64.iso.sig" >/dev/null 2>/dev/null
		echo bad signature, deleting
		rm "$TO/archlinux-x86_64.iso"
		rm "$TO/archlinux-x86_64.iso.sig"
	end
end
