#!/usr/bin/env nu

use nushell/modules/system.nu *

print "🚀 Bootstrapping dotfiles..."

let dotfiles_dir = ($nu.home-dir | path join "dev/dotfiles")
if not ($dotfiles_dir | path exists) {
    error make { msg: $"Expected ($dotfiles_dir) to exist. Clone the repo there first." }
}

print "🔗 Symlinking nushell config..."
ensure-link ($dotfiles_dir | path join "nushell") $nu.default-config-dir

nu ($dotfiles_dir | path join "helpers/link-skills.nu")

let local_file = ($nu.default-config-dir | path join "local.nu")
if not ($local_file | path exists) {
    touch $local_file
    print "✅ Created local.nu"
}

# Everything else (rustup, fnm, node, system packages, post-install setup)
# is handled by update-system via the package manifests + post-install scripts.
print "🔄 Running update-system..."
nu -c "source $nu.env-path; source $nu.config-path; update-system"

print "🎉 Installation complete!"
