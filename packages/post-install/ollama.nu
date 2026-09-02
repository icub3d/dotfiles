add-group video
add-group render
sudo usermod -aG video,render ollama

# The AMD (11434) instance's drop-in is owned by helpers/ollama-amd-override.conf,
# the same file setup-ollama-gpus.nu installs. This script used to write its own
# shorter inline copy to the same path, which dropped CUDA_VISIBLE_DEVICES=-1 and
# let the AMD instance claim the NVIDIA card out from under ollama-cuda.service.
# Read it from the one source instead of duplicating it here.
let dotfiles_root = ($nu.home-dir | path join "dev/dotfiles")
let override_src = ($dotfiles_root | path join "helpers/ollama-amd-override.conf")
let override_dir = "/etc/systemd/system/ollama.service.d"
let override_path = $"($override_dir)/override.conf"

if (not ($override_path | path exists)) or ((open $override_path) != (open $override_src)) {
    sudo mkdir -p $override_dir
    sudo cp $override_src $override_path
    sudo systemctl daemon-reload
    print "  ✅ Installed AMD Ollama override from helpers/ollama-amd-override.conf"
}
add-service ollama
