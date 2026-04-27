#!/usr/bin/env nu

use nushell/modules/system.nu *

print "🚀 Bootstrapping dotfiles..."

let dotfiles_dir = ($nu.home-dir | path join "dev/dotfiles")
if not ($dotfiles_dir | path exists) {
    error make { msg: $"Expected ($dotfiles_dir) to exist. Clone the repo there first." }
}

print "🔗 Symlinking nushell config..."
ensure-link ($dotfiles_dir | path join "nushell") $nu.default-config-dir

print "🔗 Symlinking Gemini skills..."
ensure-link ($dotfiles_dir | path join "gemini/skills") ($nu.home-dir | path join ".gemini/skills")

let env_file = ($nu.default-config-dir | path join ".env.nu")
if not ($env_file | path exists) {
    touch $env_file
    print "✅ Created .env.nu"
}

# Everything else (rustup, fnm, node, system packages, post-install setup)
# is handled by update-system via the package manifests + post-install scripts.
print "🔄 Running update-system..."
nu -c "source $nu.env-path; source $nu.config-path; update-system"

print "🎉 Installation complete!"
