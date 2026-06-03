#!/usr/bin/env nu

# Link agent skills to support multiple AI agents (Gemini, Claude, and general agents)
use ../nushell/modules/system.nu ensure-link

def main [] {
    let dotfiles_dir = ($nu.home-dir | path join "dev/dotfiles")
    let skills_src = ($dotfiles_dir | path join "agents/skills")

    if not ($skills_src | path exists) {
        print -e $"Error: ($skills_src) does not exist."
        exit 1
    }

    let targets = [
        ($nu.home-dir | path join ".agents/skills")
        ($nu.home-dir | path join ".gemini/skills")
        ($nu.home-dir | path join ".claude/skills")
    ]

    print "🔗 Symlinking agent skills..."
    for target in $targets {
        ensure-link $skills_src $target
    }
}
