# System Maintenance Module

# Appendix of dotfiles installation logic
export def dotfiles [] {
  cd ~/dev/dotfiles
  mkdir ~/.config
  if (not ("~/.config/nvim" | path exists)) { ln -s ~/dev/dotfiles/nvim ~/.config/nvim }

  # gnupg
  mkdir ~/.gnupg
  for f in ["gpg.conf", "gpg-agent.conf"] {
    if (not ($"~/.gnupg/($f)" | path exists)) {
      cp $"helpers/($f)" $"~/.gnupg/($f)"
      chmod 600 $"~/.gnupg/($f)"
    }
  }

  # make symlinks for all the files
  ls -a ~/dev/dotfiles/dotfiles/**/* | 
    where { |p| $p.type == "file" } | 
    get name | 
    each { |n| 
      let rel = ($n | str replace ($nu.home-dir | path join "dev/dotfiles/dotfiles/") "")
      let target = ($nu.home-dir | path join $rel)
      mkdir ($target | path dirname)
      if (not ($target | path exists)) { ln -s $n $target }
    }
}

# Update the entire system (Arch Linux)
export def update-system [] {
  dotfiles
  cd ~/dev/dotfiles
  
  # Configure Pacman
  sudo /usr/bin/sed -i -e 's/#Color/Color/g' /etc/pacman.conf
  sudo /usr/bin/sed -i -e 's/#ParallelDownloads = 5/ParallelDownloads = 5/g' /etc/pacman.conf

  if (not ("/usr/bin/paru" | path exists)) {
    # Install paru if missing
    print "Installing paru..."
    git clone https://aur.archlinux.org/paru.git /tmp/paru
    cd /tmp/paru
    makepkg -si --noconfirm
  }

  let selected_packages = (open .selected_packages | str trim | split row " ")
  let installed = (pacman -Q | lines | parse "{package} {version}" | get package)
  let packages = $selected_packages | each { |p| open $"packages/pacman/($p)" | lines } | flatten | where $it != ""
  let needed = $packages | where { |p| not ($p in $installed) }

  if ($needed | is-not-empty) {
    yes | paru -Syu --needed --noconfirm ...$needed
  }
  
  # Run post-install scripts
  for package in $packages {
    let script = $"packages/post-install/($package).nu"
    if ($script | path exists) {
        do -i { nu -c $"source ($script)" }
    }
  }
}
