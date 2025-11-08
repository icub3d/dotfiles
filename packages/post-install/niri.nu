do -i {
  get-marshian-images 
  get-catppuccin-walpapers

  add-user-service mako
  add-user-service noctalia
  add-service gdm

  systemctl --user add-wants niri.service mako.service
  systemctl --user add-wants niri.service noctalia.service
}
