#!/usr/bin/env nu

# Boot & Login Manager: Manage systemd-boot entry and greetd configuration

# ANSI formatting helpers
def cyan [text: string] { $"(ansi cyan)($text)(ansi reset)" }
def green [text: string] { $"(ansi green)($text)(ansi reset)" }
def red [text: string] { $"(ansi red)($text)(ansi reset)" }
def yellow [text: string] { $"(ansi yellow)($text)(ansi reset)" }
def gray [text: string] { $"(ansi light_gray)($text)(ansi reset)" }
def bold [text: string] { $"\u{1b}[1m($text)(ansi reset)" }

# Check if sudo can be run without prompting for a password (non-interactive)
def can-run-sudo [] {
    (do { sudo -n true } | complete | get exit_code) == 0
}

# Read boot config file safely using sudo if standard read fails and passwordless sudo is available
def read-boot-conf [] {
    let path = "/boot/loader/entries/arch.conf"
    
    # Try direct open first (in case running as root or /boot is readable)
    try {
        if ($path | path exists) {
            return (open $path)
        }
    } catch {}
    
    # If direct read fails, fall back to sudo only if it is passwordless
    if (can-run-sudo) {
        let res = (do { sudo cat $path } | complete)
        if $res.exit_code == 0 {
            return $res.stdout
        }
    }
    
    null
}

# Write boot config file safely using sudo
def write-boot-conf [content: string] {
    let path = "/boot/loader/entries/arch.conf"
    let temp_file = "/tmp/arch.conf.tmp"
    
    # Save locally to temp first
    $content | save --force $temp_file
    
    # Copy using sudo (this will prompt for password if interactive, which is correct for apply commands)
    let res = (do { sudo cp $temp_file $path } | complete)
    let rm_res = (rm -f $temp_file)
    
    if $res.exit_code == 0 {
        # Set proper permissions for the ESP entry (usually readable by all, but owned by root)
        do { sudo chmod 644 $path } | complete
        true
    } else {
        print (red $"Error copying to ($path): ($res.stderr)")
        false
    }
}

# Detect the root partition UUID dynamically
def detect-root-uuid [] {
    let res = (do { findmnt -n -o UUID / } | complete)
    if $res.exit_code == 0 {
        $res.stdout | str trim
    } else {
        # Fallback to a well-known UUID from the user request
        "ee9eb112-11f6-42c1-a5aa-893dbf4452bd"
    }
}

# Check greetd service status
def greetd-service-status [] {
    let res = (do { systemctl is-active greetd } | complete)
    let active = ($res.stdout | str trim) == "active"
    
    let res_enabled = (do { systemctl is-enabled greetd } | complete)
    let enabled = ($res_enabled.stdout | str trim) == "enabled"
    
    { active: $active, enabled: $enabled }
}

# 🔍 Audit both boot and greetd configuration status
export def check [] {
    print $"\n(cyan '🪐 Boot & Login Manager Status Check')"
    print (gray "==================================================")
    
    let dotfiles_root = ($nu.home-dir | path join "dev/dotfiles")
    let repo_greetd_path = ($dotfiles_root | path join "etc-greetd-config.toml")
    let sys_greetd_path = "/etc/greetd/config.toml"
    
    # --- greetd Configuration Section ---
    print $"\n(bold '1. Greetd Configuration (Login Greeter)')"
    
    if not ($repo_greetd_path | path exists) {
        print $"  ⚠️ Repository template (etc-greetd-config.toml) not found at: ($repo_greetd_path)"
    } else if not ($sys_greetd_path | path exists) {
        print $"  ❌ ($sys_greetd_path) does not exist! greetd may not be installed."
    } else {
        let repo_greetd = (open $repo_greetd_path | str trim)
        let sys_greetd = (open $sys_greetd_path | str trim)
        
        let match = ($repo_greetd == $sys_greetd)
        let service = (greetd-service-status)
        
        let match_str = if $match {
            green 'MATCH'
        } else {
            red 'MISMATCH'
        }
        let match_desc = if $match {
            gray '(/etc/greetd/config.toml matches repo)'
        } else {
            yellow '(System configuration is out-of-sync with repo)'
        }
        print $"  Config Match: ($match_str) ($match_desc)"
        
        let service_status_str = if $service.active {
            (green 'ACTIVE & RUNNING')
        } else {
            (red 'INACTIVE')
        }
        
        let service_enabled_str = if $service.enabled {
            (green 'ENABLED')
        } else {
            (red 'DISABLED')
        }
        
        print $"  Service State: ($service_status_str)"
        print $"  Service Boot:  ($service_enabled_str)"
    }
    
    # --- systemd-boot Entry Section ---
    print $"\n(bold '2. systemd-boot configuration (/boot/loader/entries/arch.conf)')"
    
    let detected_uuid = (detect-root-uuid)
    let current_boot = (read-boot-conf)
    
    # Desired option parts to audit
    let expected_options = [
        "pcie_port_pm=off"
        "pcie_aspm.policy=performance"
        "quiet"
        "loglevel=3"
        "vt.default_red=48,231,166,229,140,244,129,181,98,231,166,229,140,244,129,165"
        "vt.default_grn=52,130,209,200,170,184,200,191,104,130,209,200,170,184,200,173"
        "vt.default_blu=70,132,137,144,238,228,190,226,128,132,137,144,238,228,190,206"
    ]
    
    if ($current_boot == null) {
        if not (can-run-sudo) {
            print $"  Status: (yellow 'ACCESS RESTRICTED (requires sudo)')"
            print $"  Note: `/boot/loader/entries/arch.conf` requires root privileges to read."
            print $"        Please run this check with sudo to view full details:"
            print $"        (bold 'sudo nu helpers/boot-login.nu check')"
        } else {
            print $"  Status: (red 'NOT FOUND or UNREADABLE')"
            print $"  Target Root UUID: ($detected_uuid)"
            print $"  Recommended: Run `sudo nu helpers/boot-login.nu apply-boot` to generate/write the entry."
        }
    } else {
        print $"  Status: (green 'FOUND & READABLE')"
        
        # Verify lines
        let lines = ($current_boot | lines | str trim)
        let title_line = ($lines | find "title " | first? | default "")
        let linux_line = ($lines | find "linux " | first? | default "")
        let initrd_lines = ($lines | find "initrd ")
        let options_line = ($lines | find "options " | first? | default "")
        
        # Parse root UUID from system
        let current_uuid = if ($options_line | str contains "root=") {
            try {
                $options_line | parse --regex 'root=(?:UUID=)?"?([^"\s]+)"?' | get 0.capture0
            } catch {
                "Unknown"
            }
        } else {
            "None"
        }
        
        # Print diagnostic details
        print $"  Title:   ($title_line)"
        print $"  Linux:   ($linux_line)"
        print $"  Initrd:  ($initrd_lines | str join ', ')"
        
        let uuid_match_str = if $current_uuid == $detected_uuid {
            green 'MATCH'
        } else {
            red $"MISMATCH! System root is ($detected_uuid)"
        }
        print $"  UUID:    ($current_uuid) ($uuid_match_str)"
        
        # Check kernel option toggles
        print $"\n  Kernel Options Audit:"
        let has_options = ($options_line | is-not-empty)
        
        for opt in $expected_options {
            let present = ($options_line | str contains $opt)
            if $present {
                print $"    [✅] ($opt)"
            } else {
                let missing_lbl = yellow '(missing)'
                print $"    [❌] ($opt) ($missing_lbl)"
            }
        }
        
        # Overall check
        let missing_options = ($expected_options | where { |opt| not ($options_line | str contains $opt) })
        let boot_ok = ($current_uuid == $detected_uuid and ($missing_options | is-empty))
        
        print ""
        if $boot_ok {
            let perf_desc = gray '(all performance features and console colors are active)'
            print $"  Boot Config Audit: (green 'PERFECT') ($perf_desc)"
        } else {
            let sync_desc = yellow '(run apply-boot to sync kernel parameters and colors)'
            print $"  Boot Config Audit: (red 'OUT OF SYNC') ($sync_desc)"
        }
    }
}

# 🚀 Apply the greetd login configuration from the repository
export def apply-greetd [] {
    let dotfiles_root = ($nu.home-dir | path join "dev/dotfiles")
    let repo_greetd_path = ($dotfiles_root | path join "etc-greetd-config.toml")
    let sys_greetd_path = "/etc/greetd/config.toml"
    
    if not ($repo_greetd_path | path exists) {
        error make { msg: $"Repository etc-greetd-config.toml not found at: ($repo_greetd_path)" }
    }
    
    print $"🔄 Deploying greetd configuration to ($sys_greetd_path)..."
    
    # Copy file using sudo
    let res = (do { sudo cp $repo_greetd_path $sys_greetd_path } | complete)
    if $res.exit_code != 0 {
        error make { msg: $"Failed to copy greetd config: ($res.stderr)" }
    }
    
    # Set correct permissions (greetd expects 644/root ownership)
    do { sudo chmod 644 $sys_greetd_path } | complete
    do { sudo chown root:root $sys_greetd_path } | complete
    
    print "⚙️ Enabling and starting greetd.service..."
    let svc_enable = (do { sudo systemctl enable greetd } | complete)
    let svc_start = (do { sudo systemctl restart greetd } | complete)
    
    if $svc_start.exit_code == 0 {
        print (green "✅ Greetd login configuration successfully updated and service is running.")
    } else {
        print (red $"⚠️ Config updated but service failed to restart: ($svc_start.stderr)")
    }
}

# 🚀 Apply systemd-boot configurations with performance settings and Catppuccin console colors
export def apply-boot [--uuid: string] {
    let resolved_uuid = if ($uuid | is-empty) {
        let detected = (detect-root-uuid)
        print $"🔍 Detected Root UUID: ($detected)"
        $detected
    } else {
        $uuid
    }
    
    print "✍️ Constructing `/boot/loader/entries/arch.conf`..."
    
    let arch_conf_content = [
        "title Arch Linux"
        "linux /vmlinuz-linux"
        "initrd /amd-ucode.img"
        "initrd /initramfs-linux.img"
        $"options root=UUID=\"($resolved_uuid)\" rw pcie_port_pm=off pcie_aspm.policy=performance quiet loglevel=3 vt.default_red=48,231,166,229,140,244,129,181,98,231,166,229,140,244,129,165 vt.default_grn=52,130,209,200,170,184,200,191,104,130,209,200,170,184,200,173 vt.default_blu=70,132,137,144,238,228,190,226,128,132,137,144,238,228,190,206"
    ] | str join "\n"
    
    print $"🔄 Writing configuration to `/boot/loader/entries/arch.conf`..."
    let success = (write-boot-conf $arch_conf_content)
    
    if $success {
        print (green "✅ systemd-boot configuration successfully updated with custom kernel flags and console colors.")
    } else {
        error make { msg: "Failed to write boot configuration. Make sure you enter your password when sudo prompts." }
    }
}

# 🚀 Apply both boot parameters and greetd configurations in one command
export def apply-all [] {
    print (cyan "🚀 Starting Full Boot and Login Manager Setup...")
    apply-greetd
    print ""
    apply-boot
    print "\n"
    check
}

# Default entrypoint runs the audit check
def main [] {
    check
}
