do -i {
  get-marshian-images 
  get-catppuccin-walpapers

  add-user-service noctalia
  add-service gdm

  systemctl --user add-wants niri.service noctalia.service
}
