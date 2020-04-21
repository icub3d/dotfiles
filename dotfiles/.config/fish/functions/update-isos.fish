function update-isos
	set TO $argv[1]

	for i in $TO/archlinux*.iso $TO/kali-linux*.iso
		rm $i
	end

	download-arch-iso $TO
	download-kali-iso $TO
end
