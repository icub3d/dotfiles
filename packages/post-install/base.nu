let dotfiles_root = ($nu.home-dir | path join "dev/dotfiles")
tic -x -o ($nu.home-dir | path join ".terminfo") ($dotfiles_root | path join "xterm-24bit.terminfo")

let perf_conf = "/etc/sysctl.d/100-perf.conf"
let inotify_conf = "/etc/sysctl.d/99-inotify.conf"
let perf_desired = "kernel.perf_event_paranoid=-1\n"
let inotify_desired = "fs.inotify.max_user_watches=524288\n"

mut reload = false
if (not ($perf_conf | path exists)) or ((open $perf_conf) != $perf_desired) {
  $perf_desired | sudo tee $perf_conf out> /dev/null
  $reload = true
}
if (not ($inotify_conf | path exists)) or ((open $inotify_conf) != $inotify_desired) {
  $inotify_desired | sudo tee $inotify_conf out> /dev/null
  $reload = true
}
if $reload { sudo sysctl --system }
