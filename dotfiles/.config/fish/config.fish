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
set -g __fish_git_prompt_char_cleanstate ' 👍 '
set -g __fish_git_prompt_char_conflictedstate '⛔ '
set -g __fish_git_prompt_char_dirtystate ' 💩 '
set -g __fish_git_prompt_char_invalidstate ' 🤮 '
set -g __fish_git_prompt_char_stagedstate ' 🚥 '
set -g __fish_git_prompt_char_stashstate ' 📦 '
set -g __fish_git_prompt_char_stateseparator ' '
set -g __fish_git_prompt_char_untrackedfiles ' 🔍 '
set -g __fish_git_prompt_char_upstream_ahead ' 👆 '
set -g __fish_git_prompt_char_upstream_behind ' 👇 '
set -g __fish_git_prompt_char_upstream_diverged ' 🚧 '
set -g __fish_git_prompt_char_upstream_equal ' 💯 '


# Fix the colors that don't seem to work right
set -x fish_color_param green

# Run all of our sub scripts.
for SCRIPT in $HOME/.config/fish/config.d/*.fish
	source $SCRIPT
end

