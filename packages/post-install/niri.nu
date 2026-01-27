do -i {
  add-user-service noctalia
  systemctl --user add-wants niri.service noctalia.service
}
