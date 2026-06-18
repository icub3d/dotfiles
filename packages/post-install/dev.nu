mkdir ($nu.home-dir | path join "bin")

# Rust toolchains/components/targets — rustup is idempotent.
let toolchains = (rustup toolchain list)
let targets = (rustup target list --installed)

if not ($toolchains | str contains "nightly") {
    rustup toolchain add nightly
}
if not ($toolchains | str contains "stable") {
    rustup default stable
}

let active_components = (rustup component list --installed)
for comp in ["rust-analysis", "rust-src", "rust-analyzer"] {
    if not ($active_components | str contains $comp) {
        rustup component add $comp
    }
}
if not ($targets | str contains "wasm32-unknown-unknown") {
    rustup target add wasm32-unknown-unknown
}

let nightly_components = (rustup component list --toolchain nightly --installed)
for comp in ["rust-analysis", "rust-src", "rust-analyzer"] {
    if not ($nightly_components | str contains $comp) {
        rustup component add --toolchain nightly $comp
    }
}
let nightly_targets = (rustup target list --toolchain nightly --installed)
if not ($nightly_targets | str contains "wasm32-unknown-unknown") {
    rustup target add --toolchain nightly wasm32-unknown-unknown
}

if (which tree-sitter | is-empty) {
    cargo install tree-sitter-cli
}

# Helper to install/update a binary from GitHub releases
def install-github-binary [
    repo: string,           # e.g. "stern/stern"
    bin_name: string,       # e.g. "stern"
    asset_suffix: string    # e.g. "linux_amd64.tar.gz"
] {
    let bin_dir = ($nu.home-dir | path join "bin")
    let bin_path = ($bin_dir | path join $bin_name)

    # Check local version if binary exists
    mut local_ver = ""
    if ($bin_path | path exists) {
        $local_ver = (try {
            # Run the binary to get its version
            let version_output = (run-external $bin_path "--version" | complete | get stdout)
            let parsed = ($version_output | parse -r "(?P<ver>\\d+\\.\\d+\\.\\d+)")
            if ($parsed | is-empty) { "" } else { $parsed | get 0.ver }
        } catch { "" })
    }

    # Fetch latest release info
    print $"Checking latest release for ($repo)..."
    let release = (try {
        http get $"https://api.github.com/repos/($repo)/releases/latest"
    } catch {
        print $"⚠️ Failed to fetch latest release for ($repo) from GitHub API."
        null
    })

    if $release == null {
        return
    }

    let latest_ver = (try {
        let parsed = ($release.tag_name | parse -r "(?P<ver>\\d+\\.\\d+\\.\\d+)")
        if ($parsed | is-empty) { "" } else { $parsed | get 0.ver }
    } catch { "" })

    if ($latest_ver | is-empty) {
        print $"⚠️ Could not parse latest version from tag: ($release.tag_name)"
        return
    }

    if ($local_ver == $latest_ver) {
        print $"✅ ($bin_name) is already up-to-date [version: ($local_ver)]"
        return
    }

    print $"🚀 Installing ($bin_name) ($latest_ver) [current: ($local_ver)]..."
    let matching_assets = ($release.assets | where name ends-with $asset_suffix)
    if ($matching_assets | is-empty) {
        print $"❌ No asset found ending with '($asset_suffix)' for ($repo)"
        return
    }

    let download_url = ($matching_assets | get 0.browser_download_url)
    let tmp_dir = (mktemp -d)
    let tar_path = ($tmp_dir | path join $"($bin_name).tar.gz")

    print $"  Downloading ($download_url)..."
    try {
        http get $download_url | save -f $tar_path
        print "  Extracting archive..."
        tar -xzf $tar_path -C $tmp_dir

        let unpacked_files = (
            glob $"($tmp_dir)/**/*"
            | where { |it|
                ($it | path basename) == $bin_name and (try { ls -d $it | get 0.type } catch { "file" }) == "file"
            }
        )
        if ($unpacked_files | is-not-empty) {
            let found_bin = ($unpacked_files | first)
            mkdir $bin_dir
            cp -f $found_bin $bin_path
            chmod +x $bin_path
            print $"✅ Successfully installed ($bin_name) to ($bin_path)"
        } else {
            print $"❌ Binary ($bin_name) not found in the extracted archive."
        }
    } catch { |err|
        print $"❌ Failed to install ($bin_name): ($err.msg)"
    }

    # Clean up tmp
    try { rm -rf $tmp_dir } catch {}
}

# Install or update GitHub release binaries
install-github-binary "stern/stern" "stern" "linux_amd64.tar.gz"
install-github-binary "blacknon/hwatch" "hwatch" "x86_64-unknown-linux-gnu.tar.gz"

