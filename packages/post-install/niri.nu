do -i {
  get-marshian-images 
  get-catppuccin-walpapers

  systemctl --user add-wants niri.service mako.service
  systemctl --user add-wants niri.service noctalia.service
  sudo systemctl enable lemurs
}
