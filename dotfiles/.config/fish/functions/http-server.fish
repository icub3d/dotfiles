function http-server
    if command -vq miniserve
        command miniserve $argv
    else
        command http-server $argv
    end 
end
