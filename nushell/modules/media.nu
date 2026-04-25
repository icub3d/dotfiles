# Media and Video Processing Module

# Shorten an mkv file to 25 seconds and save it to path-short.mkv.
export def "shorten-video" [
    file: path # The path to the input MKV file.
] {
    let target_duration = 25.0
    let normal_speed_duration = 10.0
    let sped_up_duration = 15.0
    
    let file_path = ($file | path expand)
    if not ($file_path | path exists) {
        print $"🚨 Error: File not found: ($file_path)"
        return
    }

    let duration_output = (
        ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 $file_path | lines | get 0
    )

    if ($duration_output | is-empty) {
        print $"🚨 Error: Could not determine duration for ($file_path)."
        return
    }
    
    let original_duration = ($duration_output | into float)
    let path_parts = ($file_path | path parse)
    let output_path = ($path_parts.parent | path join $"($path_parts.stem)-short.($path_parts.extension)")

    if ($original_duration) <= $target_duration {
        cp $file_path $output_path
        print "✅ File copied (already short enough)."
    } else {
        let first_part_original_duration = ($original_duration - $normal_speed_duration)
        let speed_factor = ($first_part_original_duration / $sped_up_duration)
        let second_part_start = $first_part_original_duration

        let atempo_filter = if $speed_factor > 100.0 {
            let first_factor = 100.0
            let remainder_factor = ($speed_factor / $first_factor)
            $"atempo=($first_factor),atempo=($remainder_factor)"
        } else {
            $"atempo=($speed_factor)"
        }

        let pts_factor = (1.0 / $speed_factor)
        let filter_complex = $"[0:v]trim=end=($second_part_start),setpts=($pts_factor)*PTS[v1];[0:a]atrim=end=($second_part_start),($atempo_filter),asetpts=PTS-STARTPTS[a1];[0:v]trim=start=($second_part_start),setpts=PTS-STARTPTS[v2];[0:a]atrim=start=($second_part_start),asetpts=PTS-STARTPTS[a2];[v1][a1][v2][a2]concat=n=2:v=1:a=1[outv][outa]"

        ffmpeg -hide_banner -loglevel error -i $file_path -filter_complex $filter_complex -map "[outv]" -map "[outa]" -c:v libx264 -preset veryfast -crf 23 -c:a aac -b:a 192k $output_path -y
        print "✅ FFmpeg processing complete."
    }
}

# A helper function that will put an image in front of a video and add random audio.
export def "make-kattis-short" [
    image_path: path,
    video_path: path,
    audio_folder: path,
    output_name: path,
] {
    let audio_candidates = (ls $audio_folder | where name =~ '(?i)\.(mp3|wav|flac|m4a|aac|ogg)$')
    if ($audio_candidates | is-empty) {
        error make {msg: $"❌ No audio files found in ($audio_folder)!"}
    }

    let selected_audio = ($audio_candidates | shuffle | first).name
    let metadata = (ffprobe -v error -select_streams v:0 -show_entries stream=width,height,r_frame_rate -show_entries format=duration -of json $video_path | from json)

    let width = $metadata.streams.0.width
    let height = $metadata.streams.0.height
    let fps_string = $metadata.streams.0.r_frame_rate
    let video_duration = ($metadata.format.duration | into float)
    let raw_fps = ($fps_string | split row "/" | into int | reduce { |it, acc| $it / $acc })
    let fps = if $raw_fps < 1.0 { 30 } else { $raw_fps }

    let img_len = 2.0
    let vid_fade_len = 0.5
    let vid_offset = ($img_len - $vid_fade_len)
    let total_len = ($video_duration + $img_len - $vid_fade_len)
    let aud_fade_len = 2.0
    let aud_fade_start = ($total_len - $aud_fade_len)

    let filter = $"[0:v]scale=($width):($height):force_original_aspect_ratio=decrease,pad=($width):($height):(ow-iw)/2:(oh-ih)/2,setsar=1,format=yuv420p,fps=($fps),settb=1/($fps)[img];[1:v]format=yuv420p,setsar=1,fps=($fps),settb=1/($fps)[vid];[img][vid]xfade=transition=fade:duration=($vid_fade_len):offset=($vid_offset)[v];[2:a]afade=t=out:st=($aud_fade_start):d=($aud_fade_len)[a]"

    ffmpeg -y -hide_banner -loglevel error -stats -loop 1 -t $img_len -r $fps -i $image_path -i $video_path -i $selected_audio -filter_complex $filter -map "[v]" -map "[a]" -c:v libx264 -preset fast -crf 23 -c:a aac -b:a 192k -shortest $output_name
}

# Remove audio from a video file
export def "make-kattis-short-no-sound" [file: path] {
    let file_path = ($file | path expand)
    let path_parts = ($file_path | path parse)
    let output_path = ($path_parts.parent | path join $"($path_parts.stem)-no-sound.($path_parts.extension)")
    ffmpeg -y -hide_banner -loglevel error -stats -i $file_path -c:v copy -an $output_path
}
