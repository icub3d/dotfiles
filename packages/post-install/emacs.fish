#!/usr/bin/fish

if not grep -qxF 'fs.inotify.max_user_watches=524288' /etc/sysctl.conf
    echo -e '\nfs.inotify.max_user_watches=524288' | sudo tee -a /etc/sysctl.conf
    sudo sysctl -p
end

# pre-install our emacs packages.
if not test -d $HOME/.emacs.d
    emacs -batch -l $HOME/.emacs >/dev/null ^/dev/null
end
