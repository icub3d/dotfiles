set -U fish_greeting ""

# Options
set -g __fish_git_prompt_show_informative_status 1
set -g __fish_git_prompt_showcolorhints 1
set -g __fish_git_prompt_hide_untrackedfiles 1
set -g __fish_git_prompt_showupstream "informative"

# Colors
set -g green (set_color green)
set -g magenta (set_color magenta)
set -g cyan (set_color cyan)
set -g normal (set_color normal)
set -g red (set_color red)
set -g yellow (set_color yellow)

set -g __fish_git_prompt_color_branch cyan --bold
set -g __fish_git_prompt_color_dirtystate white
set -g __fish_git_prompt_color_invalidstate red
set -g __fish_git_prompt_color_merging yellow
set -g __fish_git_prompt_color_stagedstate yellow
set -g __fish_git_prompt_color_upstream_ahead green
set -g __fish_git_prompt_color_upstream_behind red

# Icons
set -g __fish_git_prompt_char_cleanstate '📗 '
set -g __fish_git_prompt_char_conflictedstate '📒 '
set -g __fish_git_prompt_char_dirtystate ' 📙 '
set -g __fish_git_prompt_char_invalidstate ' 📙 '
set -g __fish_git_prompt_char_stagedstate ' ✏ '
set -g __fish_git_prompt_char_stashstate ' 📦 '
set -g __fish_git_prompt_char_stateseparator ' '
set -g __fish_git_prompt_char_untrackedfiles ' 📚 '
set -g __fish_git_prompt_char_upstream_ahead ' 📤 '
set -g __fish_git_prompt_char_upstream_behind ' 📥 '
set -g __fish_git_prompt_char_upstream_diverged ' 🚧 '
set -g __fish_git_prompt_char_upstream_equal ' 📘 '


# Fix the colors that don't seem to work right
set -U fish_color_cwd green
set -U fish_color_user yellow
set -U fish_color_command blue
set -x fish_color_param green

# fzf.fish options
set fzf_preview_dir_cmd exa -al --color=always --icons
set fzf_fd_opts --hidden --exclude=.git

# Figure out where we with some important binaries and our host.
if command -vq hostname
   set HOSTNAME (hostname)
else if test -f /etc/hostname
   set HOSTNAME (cat /etc/hostname)
end

set -U FISHBIN /usr/bin/fish
if test -f /usr/local/bin/fish
	set -U FISHBIN /usr/local/bin/fish
end

# Run all of our sub scripts.
for SCRIPT in $HOME/.config/fish/config.d/*.fish
	source $SCRIPT
end

# Generated for envman. Do not edit.
test -s "$HOME/.config/envman/load.fish"; and source "$HOME/.config/envman/load.fish"

# XDG_RUNTIME_DIR
if test -z "$XDG_RUNTIME_DIR"
    set -x XDG_RUNTIME_DIR /run/user/$UID
    if ! test -d "$XDG_RUNTIME_DIR"
        set -x XDG_RUNTIME_DIR /tmp/$USER-runtime
        if ! test -d "$XDG_RUNTIME_DIR"
            mkdir -m 0700 "$XDG_RUNTIME_DIR"
        end
    end
end

if command -q rvm
  rvm default
end
