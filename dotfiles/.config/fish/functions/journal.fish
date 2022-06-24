function journal
    set PARENT_ID 0B5YUyAh2IEDHMDlmMTk4ZDQtMDQ2Mi00OTFjLWI3NWMtZTE3MzNkOGJjYTFl
    set UPLOAD_NAME gs://marshians-tts/audio.flac
    ffmpeg -i $argv[1] -ac 1 audio.flac
    gsutil cp audio.flac $UPLOAD_NAME
    rm audio.flac
    set OPID (gcloud ml speech recognize-long-running --async --language-code='en-US' $UPLOAD_NAME 2>/dev/null | jq -c '.name' | sed 's/"//g')
    gcloud ml speech operations wait $OPID>$argv[1].tts.json
    jq -c '.results[].alternatives[0].transcript' $argv[1].tts.json | sed 's/"//g' > $argv[1].tts.txt
    gdrive upload --parent $PARENT_ID $argv[1]
    gdrive upload --parent $PARENT_ID $argv[1].tts.json
    gdrive upload --parent $PARENT_ID $argv[1].tts.txt
end
