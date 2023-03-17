#!/usr/bin/fish

function mctl
	if test $argv[1] = "images"
		if test $argv[2] = "put"
			set TAGS (echo $argv[3] | sed 's/[ .-]/,/g')
			set MIME (file -b --mime-type "$argv[3]") 
			imagesctl -u (cat $HOME/Documents/ssssh/mongo-images-uri) put $argv[3] "$MIME" "$TAGS"
      		aws s3 cp --endpoint-url=https://s3.us-west-1.wasabisys.com $argv[3] s3://img.marsh.gg/
			echo "https://img.marsh.gg/$argv[3]"
		else
			echo "unknown command for images: $argv[2]"
		end
	else
		echo "unknown command: $argv[1]"
	end
end
