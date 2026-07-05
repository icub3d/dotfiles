let dotfiles_root = ($nu.home-dir | path join "dev/dotfiles")
let conf_src = ($dotfiles_root | path join "helpers/reflector.conf")
let conf_dest = "/etc/xdg/reflector/reflector.conf"
let conf_dir = ($conf_dest | path dirname)

if not ($conf_dir | path exists) {
    sudo mkdir -p $conf_dir
}

# Only copy/overwrite if they differ or it doesn't exist
if (not ($conf_dest | path exists)) or ((open $conf_dest) != (open $conf_src)) {
    sudo cp $conf_src $conf_dest
    print "  ✅ Copied reflector.conf to /etc/xdg/reflector/reflector.conf"
}

add-service reflector
