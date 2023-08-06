#!/usr/bin/fish

function mctl
	if test $argv[1] = "images"
		if test $argv[2] = "put"
			set MONGO_URI (bw-get-token mongo-bank-cloud-uri)
			for image in $argv[3..]
				set TAGS (echo $image | sed 's/[ .-]/,/g')
				set MIME (file -b --mime-type "$image")
				imagesctl -u "$MONGO_URI" put "$image" "$MIME" "$TAGS"
				aws s3 cp --endpoint-url=https://s3.us-west-1.wasabisys.com $image s3://img.marsh.gg/
				echo "https://img.marsh.gg/$image"
			end
		else
			echo "unknown command for images: $argv[2]"
		end
	else
		echo "unknown command: $argv[1]"
	end
end
