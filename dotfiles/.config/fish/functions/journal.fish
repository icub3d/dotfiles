function journal
    set PARENT_ID (cat ~/Documents/ssssh/family-journal-id)
	set BASE_NAME (basename -s .mkv $argv[1])
    ffmpeg -i $argv[1] -vn -acodec copy $BASE_NAME.aac
	whisper $BASE_NAME.aac --model medium --language en
	for i in $BASE_NAME*
		gdrive files upload --parent $PARENT_ID "$i"
	end
end
