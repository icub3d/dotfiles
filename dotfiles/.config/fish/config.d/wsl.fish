#!/usr/bin/fish

if string match -r WSL (uname -r) >/dev/null
  # SSH Socket
  set -x SSH_AUTH_SOCK $HOME/.ssh/agent.sock 
  if ! ss -a | grep -q $SSH_AUTH_SOCK 
    rm -f $SSH_AUTH_SOCK
    setsid nohup socat UNIX-LISTEN:$SSH_AUTH_SOCK,fork EXEC:$HOME/.ssh/wsl2-ssh-pageant.exe &>/dev/null &
  end
  
  # GPG Socket
  set -x GPG_AGENT_SOCK $HOME/.gnupg/S.gpg-agent 
  if ! ss -a | grep -q $GPG_AGENT_SOCK 
    rm -rf $GPG_AGENT_SOCK
    setsid nohup socat UNIX-LISTEN:$GPG_AGENT_SOCK,fork EXEC:"$HOME/.ssh/wsl2-ssh-pageant.exe --gpg S.gpg-agent" &>/dev/null &
  end
end
