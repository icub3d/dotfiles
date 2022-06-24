#!/usr/bin/fish

function mctl
	if test $argv[1] = "images"
		if test $argv[2] = "put"
			set TAGS (echo $argv[3] | sed 's/[ .-]/,/g')
			set MIME (file -b --mime-type "$argv[3]") 
			imagesctl -u 'mongodb://images:gxyE7kTcjHQxSzrwJC3b@mongodb-0.marsh.gg:27017,mongodb-1.marsh.gg:27017,mongodb-2.marsh.gg:27017/images?tls=true' put $argv[3] "$MIME" "$TAGS"
			echo "https://i.marsh.gg/api/media/$argv[3]"
		else if test $argv[2] = "rm"
			mongo 'mongodb://srv2:27017/images' --eval "db.media.remove({_id:\"$argv[3]\"});db.chunks.remove({filename:\"$argv[3]\"});"
		else
			echo "unknown command for images: $argv[2]"
		end
	else if test $argv[1] = "links"
		if test $argv[2] = "put"
			set cmd "db.links.insert({'_id': '$argv[3]', 'link': '$argv[4]'});"
			ssh srv2 "docker exec -i marshians_mongo_1 mongo links --eval \"$cmd\""
		else
			echo "unknown command for links: $argv[2]"
		end
	else
		echo "unknown command: $argv[1]"
	end
end
