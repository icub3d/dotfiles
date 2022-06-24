function download-kali-iso
	set BASEURL "https://cdimage.kali.org/current"
	set TO $argv[1]
	
	# Get the latest
	set ISO (http -F "$BASEURL" | rg -o 'kali-linux-[.0-9a-z]+-live.amd64.iso' | sort | uniq)

	# Download ISO
	http -F "$BASEURL/$ISO" > "$TO/kali-linux-live-amd64.iso"

	# Download sha and sigs
	http -F "$BASEURL/SHA256SUMS" > "$TO/SHA256SUMS"
	http -F "$BASEURL/SHA256SUMS.gpg" > "$TO/SHA256SUMS.gpg"

	# verify sig
	if not gpg -q --keyserver-options auto-key-retrieve --verify "$TO/SHA256SUMS.gpg" "$TO/SHA256SUMS" >/dev/null 2>/dev/null
		echo bad signature, deleting
		rm "$TO/kali-linux-live-amd64.iso"
		rm "$TO/SHA256SUMS"
		rm "$TO/SHA256SUMS.gpg"
		return
	end

	# verify hash
	set EXPSHA256SUM (cat "$TO/SHA256SUMS" | rg $ISO | cut -d' ' -f1)
	set SHA256SUM (shasum -a 256 "$TO/kali-linux-live-amd64.iso" | cut -d' ' -f1)
	if not test "$EXPSHA256SUM" = "$SHA256SUM"
		echo hashes do not match, deleting
		rm "$TO/kali-linux-live-amd64.iso"
	end
	
	rm "$TO/SHA256SUMS"
	rm "$TO/SHA256SUMS.gpg"
end
