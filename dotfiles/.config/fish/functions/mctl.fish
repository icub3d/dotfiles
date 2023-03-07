#!/usr/bin/fish

function mctl
	if test $argv[1] = "images"
		if test $argv[2] = "put"
			set TAGS (echo $argv[3] | sed 's/[ .-]/,/g')
			set MIME (file -b --mime-type "$argv[3]") 
			imagesctl -u (cat $HOME/Documents/ssssh/mongo-images-uri) put $argv[3] "$MIME" "$TAGS"
			echo "https://i.marsh.gg/api/media/$argv[3]"
		else if test $argv[2] = "rm"
			mongo (cat $HOME/Documents/ssssh/mongo-images-uri) --eval "db.media.remove({_id:\"$argv[3]\"});db.chunks.remove({filename:\"$argv[3]\"});"
		else
			echo "unknown command for images: $argv[2]"
		end
	else
		echo "unknown command: $argv[1]"
	end
end
