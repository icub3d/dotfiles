do -i {
  add-user-service noctalia
  add-service gdm

  systemctl --user add-wants niri.service noctalia.service
}
