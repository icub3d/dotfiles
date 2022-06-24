function plymouth-preview
    command plymouthd
    command plymouth --show-splash
    command sleep 10
    command plymouth quit
end