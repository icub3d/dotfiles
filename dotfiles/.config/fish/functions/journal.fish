function journal
    set PARENT_ID 13eZGH0LoNUJ2Y1YhNE5_dfo7p0pfKoci
	set BASE_NAME (basename -s .mkv $argv[1])
    ffmpeg -i $argv[1] -vn -acodec copy $BASE_NAME.aac
	whisper $BASE_NAME.aac --model medium --language en
	for i in $BASE_NAME*
		gdrive files upload --parent $PARENT_ID "$i"
	end
end
