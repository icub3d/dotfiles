#!/usr/bin/fish

function mctl
	if test $argv[1] = "images"
		if test $argv[2] = "put"
			set MONGO_URI (bw-get-token mongo-bank-cloud-uri)
			for image in $argv[3..]
				set TAGS (echo $image | sed 's/[ .-]/,/g')
				set MIME (file -b --mime-type "$image")
				imagesctl -u "$MONGO_URI" put "$image" "$MIME" "$TAGS"
				scp "$image" srv2:/data/exports/k8s/images/
				echo "https://img.marsh.gg/$image"
			end
		else
			echo "unknown command for images: $argv[2]"
		end
	else if test $argv[1] = "files"
		if test $argv[2] = "put"
			for file in $argv[3..]
				scp "$file" srv2:/data/exports/k8s/files/
				echo "https://files.marsh.gg/$file"
			end
		else
			echo "unknown command for files: $argv[2]"
		end
	else
		echo "unknown command: $argv[1]"
	end
end
