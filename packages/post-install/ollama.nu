add-group video
add-group render
sudo usermod -aG video,render ollama

let override_dir = "/etc/systemd/system/ollama.service.d"
let override_path = $"($override_dir)/override.conf"
let desired = "[Service]
Environment=\"HSA_OVERRIDE_GFX_VERSION=11.0.0\"
Environment=\"HIP_VISIBLE_DEVICES=0\"
"
if (not ($override_path | path exists)) or ((open $override_path) != $desired) {
  sudo mkdir -p $override_dir
  $desired | sudo tee $override_path out> /dev/null
  sudo systemctl daemon-reload
}
add-service ollama
