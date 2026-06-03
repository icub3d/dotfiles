let npmrc = ($nu.home-dir | path join ".npmrc")
let npm_prefix = ($nu.home-dir | path join ".npm-packages")
if not ($npmrc | path exists) {
    $"prefix=($npm_prefix)\n" | save $npmrc
}

# Fetch the latest LTS (stable) version from remote
mut latest_version = ""
try {
    $latest_version = (fnm ls-remote --lts --latest | split row " " | first | str trim)
} catch {
    print "⚠️ Failed to fetch latest LTS version from remote."
}

let current_version = (try { fnm current | str trim } catch { "" })

if ($latest_version | is-empty) {
    # Fallback to general v24 if remote check fails
    print "⚠️ Using fallback 'v24' installation."
    $latest_version = "v24"
    fnm install $latest_version
    fnm use $latest_version
} else {
    print $"Latest stable Node.js version: ($latest_version)"
    print $"Current active Node.js version: ($current_version)"

    if $current_version == $latest_version {
        print "✅ Node.js is already up to date."
        fnm default $latest_version
        fnm use $latest_version
    } else {
        print $"🚀 Installing Node.js ($latest_version)..."
        fnm install $latest_version
        fnm default $latest_version
        fnm use $latest_version

        if ($current_version | is-not-empty) and ($current_version != "system") and ($current_version != "none") {
            print $"🧹 Uninstalling previous version ($current_version)..."
            try {
                fnm uninstall $current_version
            } catch {
                print $"⚠️ Failed to uninstall old version ($current_version)"
            }
        }
    }
}

let tsc_exists = (which tsc | is-not-empty)
if (not $tsc_exists) or ($current_version != $latest_version) {
    print "🚀 Installing/updating global npm packages..."
    npm install --global typescript neovim
}
