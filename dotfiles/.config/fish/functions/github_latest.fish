#!/usr/bin/fish

function github_latest 
    basename (http -ph "https://github.com/$argv[1]/$argv[2]/releases/latest" | \
        grep -i 'location:' | sed 's/[[:space:]]//g')
end
