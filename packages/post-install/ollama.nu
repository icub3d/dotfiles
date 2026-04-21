do -i {
  add-group video
  add-group render
  sudo usermod -aG video,render ollama

  let override_dir = "/etc/systemd/system/ollama.service.d"
  sudo mkdir -p $override_dir
  let override_conf = "[Service]
Environment=\"HSA_OVERRIDE_GFX_VERSION=11.0.0\"
Environment=\"HIP_VISIBLE_DEVICES=0\""
  echo $override_conf | sudo tee $"($override_dir)/override.conf" out> /dev/null

  sudo systemctl daemon-reload
  add-service ollama
}
