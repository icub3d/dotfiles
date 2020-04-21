#!/usr/bin/fish

function mctl
	if test $argv[1] = "images"
		if test $argv[2] = "put"
			cp -af $argv[3] ~/dev/icub3d/images/
			pushd ~/dev/icub3d/images/
			make json
			git add . 
			git commit -m "add image $argv[3]"
			git push
			popd
			echo "https://images.themarshians.com/$argv[3]"
		else if test $argv[2] = "ls"
			pushd ~/dev/icub3d/images/
			ls -alh 
			popd
		else
			echo "unknown command for images: $argv[2]"
		end
	else if test $argv[1] = "files"
		if test $argv[2] = "put"
			cp -af $argv[3] ~/dev/icub3d/files/
			pushd ~/dev/icub3d/files/
			git add . 
			git commit -m "add file $argv[3]"
			git push
			popd
			echo "https://files.themarshians.com/$argv[3]"
		else if test $argv[2] = "ls"
			pushd ~/dev/icub3d/files/
			ls -alh 
			popd
		else
			echo "unknown command for files: $argv[2]"
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
