#!/usr/bin/env nu

print "🚀 Starting dotfiles installation..."

# --- Nushell Config Symlink ---
print "JT Symlinking nushell config..."
let dotfiles_dir = ($env.HOME | path join 'dev/dotfiles')
let nushell_dir = ($dotfiles_dir | path join 'nushell')
if ($nu.default-config-dir | path exists) {
    rm -rf $nu.default-config-dir
}
ln -s $nushell_dir $nu.default-config-dir
print "✅ Nushell config linked."

# --- Create .env.nu if it doesn't exist ---
let env_file = ($nu.default-config-dir | path join '.env.nu')
if not ($env_file | path exists) {
    touch $env_file
    print "✅ Created .env.nu file."
}

# --- Install Rust ---
print "📦 Installing rustup..."
sudo pacman -S --needed --noconfirm rustup
print "✅ Rustup installed."

print "🛠️ Installing stable rust toolchain..."
rustup toolchain add stable
print "✅ Stable toolchain installed."

# --- Install fnm ---
print "📦 Installing fnm (fast node manager)..."
let fnm_dir = ($env.HOME | path join 'dev/fnm')
if not ($fnm_dir | path exists) {
    print "Cloning fnm repository..."
    cd ($env.HOME | path join 'dev')
    git clone https://aur.archlinux.org/fnm.git
    cd fnm
    print "Building and installing fnm..."
    makepkg -sic --noconfirm
    print "✅ fnm installed."
} else {
    print " fnm already installed."
}

# --- Install Node.js v24 ---
print "📦 Installing Node.js v24 via fnm..."
fnm install v24
print "✅ Node.js v24 installed."


# --- Finalizing ---
print "🔄 Updating system..."
cd ($env.HOME | path join 'dev/dotfiles')
nu -c "source $nu.env-path; source $nu.config-path; update-system"

print "🎉 Installation complete!"
