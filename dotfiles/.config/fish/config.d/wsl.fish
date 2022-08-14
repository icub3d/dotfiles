#!/usr/bin/fish

if string match -r WSL (uname -r) >/dev/null
  # ssh w/ yubikey
  set -x SSH_AUTH_SOCK "$HOME/.ssh/agent.sock"
  if not ss -a | grep -q "$SSH_AUTH_SOCK";
    rm -f "$SSH_AUTH_SOCK"
    set wsl2_ssh_pageant_bin "$HOME/.ssh/wsl2-ssh-pageant.exe"
    if test -x "$wsl2_ssh_pageant_bin";
      setsid nohup socat UNIX-LISTEN:"$SSH_AUTH_SOCK,fork" EXEC:"$wsl2_ssh_pageant_bin" >/dev/null 2>&1 &
    else
      echo >&2 "WARNING: $wsl2_ssh_pageant_bin is not executable."
    end
    set --erase wsl2_ssh_pageant_bin
  end 

  # gpg w/ yubikey
  set -x GPG_AGENT_SOCK "$HOME/.gnupg/S.gpg-agent"
  if not ss -a | grep -q "$GPG_AGENT_SOCK";
    rm -rf "$GPG_AGENT_SOCK"
    set wsl2_ssh_pageant_bin "$HOME/.ssh/wsl2-ssh-pageant.exe"
    if test -x "$wsl2_ssh_pageant_bin";
      setsid nohup socat UNIX-LISTEN:"$GPG_AGENT_SOCK,fork" EXEC:"$wsl2_ssh_pageant_bin --gpgConfigBasepath 'C:/Users/joshu/AppData/Local/gnupg' --gpg S.gpg-agent" >/dev/null 2>&1 &
    else
      echo >&2 "WARNING: $wsl2_ssh_pageant_bin is not executable."
    end
    set --erase wsl2_ssh_pageant_bin
  end

  # syncthing
  if not pidof syncthing >/dev/null
    setsid nohup syncthing serve --no-browser --home=/home/jmarsh/.config/syncthing --logfile=/home/jmarsh/.config/syncthing/syncthing.log >/dev/null 2>&1 &
  end
end
