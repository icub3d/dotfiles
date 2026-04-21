#!/usr/bin/env nu

print "🚀 Starting dotfiles installation..."

# --- Nushell Config Symlink ---
print "JT Symlinking nushell config..."
let dotfiles_dir = ($env.HOME | path join 'dev/dotfiles')
let nushell_dir = ($dotfiles_dir | path join 'nushell')

if ($nu.default-config-dir | path exists) {
    let canonical_config_dir = ($nu.default-config-dir | path expand)
    let canonical_nushell_dir = ($nushell_dir | path expand)

    if ($canonical_config_dir == $canonical_nushell_dir) {
        print "✅ Nushell config already correctly linked."
    } else {
        print "Removing existing Nushell config or incorrect symlink..."
        rm -rf $nu.default-config-dir
        ln -s $nushell_dir $nu.default-config-dir
        print "✅ Nushell config linked."
    }
} else {
    ln -s $nushell_dir $nu.default-config-dir
    print "✅ Nushell config linked."
}

# --- Gemini Skills Symlink ---
print "JT Symlinking Gemini skills..."
let gemini_dir = ($env.HOME | path join '.gemini')
let gemini_skills_source = ($dotfiles_dir | path join 'gemini/skills')
let gemini_skills_target = ($gemini_dir | path join 'skills')

if not ($gemini_dir | path exists) {
    mkdir $gemini_dir
    print "✅ Created .gemini directory."
}

if ($gemini_skills_target | path exists) {
    if not ($gemini_skills_target | path is-symlink) {
        print "Removing existing .gemini/skills directory..."
        rm -rf $gemini_skills_target
        ln -s $gemini_skills_source $gemini_skills_target
        print "✅ Gemini skills linked."
    } else {
        print "✅ Gemini skills already linked."
    }
} else {
    ln -s $gemini_skills_source $gemini_skills_target
    print "✅ Gemini skills linked."
}

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
