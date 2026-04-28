# System Maintenance Module

# Ensure a group exists and the current user is a member.
export def "add-group" [group: string] {
    sudo groupadd -f $group
    sudo usermod -aG $group (whoami | str trim)
}

# Enable and start a system service.
export def "add-service" [name: string] {
    sudo systemctl enable --now $"($name).service"
}

# Enable and start a user service.
export def "add-user-service" [name: string] {
    systemctl --user enable --now $"($name).service"
}

# Ensure $target is a symlink pointing at $src. Replaces wrong targets.
export def "ensure-link" [src: path, target: path] {
    let src_real = ($src | path expand)
    let current = if ($target | path exists) {
        try { $target | path expand } catch { "" }
    } else { "" }
    if $current == $src_real {
        print $"  ✅ ($target) already linked"
    } else {
        if ($target | path exists) { rm -rf $target }
        mkdir ($target | path dirname)
        ln -s $src_real $target
        print $"  ✅ Linked ($target) → ($src_real)"
    }
}

# 📁 Sync dotfiles into place (appendix of dotfiles installation logic)
export def dotfiles [] {
    let dotfiles_root = ($nu.home-dir | path join "dev/dotfiles")
    let saved_dir = $env.PWD
    cd $dotfiles_root

    let config_dir = ($nu.home-dir | path join ".config")
    mkdir $config_dir
    let nvim_link = ($config_dir | path join "nvim")
    if not ($nvim_link | path exists) {
        ln -s ($dotfiles_root | path join "nvim") $nvim_link
        print "  🏗  Linked nvim config"
    }

    # 🔐 gnupg
    let gnupg_dir = ($nu.home-dir | path join ".gnupg")
    mkdir $gnupg_dir
    for f in ["gpg.conf", "gpg-agent.conf"] {
        let dest = ($gnupg_dir | path join $f)
        if not ($dest | path exists) {
            cp ($dotfiles_root | path join "helpers" $f) $dest
            chmod 600 $dest
            print "  🔐 Copied ($f)"
        }
    }

    # 🔗 make symlinks for all the files
    let src_root = ($dotfiles_root | path join "dotfiles")
    let linked = (
        glob $"($src_root)/**/*" --no-dir --exclude [".git"]
        | each { |n|
            let rel = ($n | str replace $"($src_root)/" "")
            let target = ($nu.home-dir | path join $rel)
            mkdir ($target | path dirname)
            if not ($target | path exists) { ln -s $n $target }
        }
        | length
    )
    print $"  🔗 Synced ($linked) dotfile\(s\)"

    cd $saved_dir
}

# 🚀 Update the entire system (Arch Linux)
export def update-system [] {
    let dotfiles_root = ($nu.home-dir | path join "dev/dotfiles")
    let saved_dir = $env.PWD

    # ✨ Sync dotfiles
    print "💫 Syncing dotfiles..."
    dotfiles

    # ⚙️ Configure Pacman (only run sed if the toggles are still commented out)
    let pacman_conf = (open /etc/pacman.conf)
    if ($pacman_conf | str contains "#Color") {
        sudo /usr/bin/sed -i -e 's/#Color/Color/g' /etc/pacman.conf
        print "  🎨 Enabled pacman color output"
    }
    if ($pacman_conf | str contains "#ParallelDownloads = 5") {
        sudo /usr/bin/sed -i -e 's/#ParallelDownloads = 5/ParallelDownloads = 5/g' /etc/pacman.conf
        print "  ⚡ Enabled pacman parallel downloads"
    }

    # 📥 Ensure paru is installed
    if not ("/usr/bin/paru" | path exists) {
        print "  📥 Installing paru..."
        if ("/tmp/paru" | path exists) { rm -rf /tmp/paru }
        git clone https://aur.archlinux.org/paru.git /tmp/paru
        cd /tmp/paru
        makepkg -si --noconfirm
        cd $saved_dir
        rm -rf /tmp/paru
    } else {
        print "  ✅ paru already installed"
    }

    # 📦 Resolve packages to install
    if not ($dotfiles_root | path join ".selected_packages" | path exists) {
        error make { msg: "❌ .selected_packages not found" }
    }

    let selected_packages = (
        open ($dotfiles_root | path join ".selected_packages")
        | str trim
        | split row -r '\s+'
        | where { |p| $p | is-not-empty }
    )
    let installed = (pacman -Q | lines | parse "{package} {version}" | get package)
    let packages = (
        $selected_packages
        | each { |p| open ($dotfiles_root | path join "packages/pacman" $p) | lines }
        | flatten
        | where { |p| $p | is-not-empty }
    )
    let needed = ($packages | where { |p| not ($p in $installed) })

    if ($packages | is-empty) {
        print "  🫠 No packages to manage"
    } else {
        print $"  📦 Installing/upgrading ($packages | length) packages \(($needed | length) new)..."
        if ($needed | is-not-empty) {
            paru -Syu --needed --noconfirm ...$needed
        } else {
            paru -Syu --noconfirm
        }
        print "  ✅ Packages updated"
    }

    # 🔧 Run post-install scripts
    let helpers = ($nu.default-config-dir | path join "modules/system.nu")
    let post_install_scripts = (
        $packages
        | each { |p| $dotfiles_root | path join "packages/post-install" $"($p).nu" }
        | where { |s| $s | path exists }
    )
    if ($post_install_scripts | is-empty) {
        print "  🫠 No post-install scripts to run"
    } else {
        print $"  🔧 Running ($post_install_scripts | length) post-install script\(s\)..."
        for script in $post_install_scripts {
            print $"    ↳ ($script)"
            nu -c $"use ($helpers) *; source ($script)"
        }
        print "  ✅ Post-install scripts done"
    }

    cd $saved_dir
    print "🎉 System update complete!"
}
