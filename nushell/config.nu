# --- Modules ---
use modules/utils.nu *
use modules/system.nu *
use modules/kubernetes.nu *
use modules/media.nu *
# cph is namespaced (cph run, cph test, ...) to avoid clashing with the
# top-level `d`, `n`, `w` aliases below.
use modules/cph.nu

# --- Secrets & Integration ---

$env.config.shell_integration.osc133 = ($nu.os-info.name != "windows")
$env.config.shell_integration.osc2 = true
$env.config.shell_integration.osc7 = true


# Load environment from system profiles (Linux only)
if ($nu.os-info.name == "linux") {
    let profile_env = (bash -c "[ -f /etc/profile ] && source /etc/profile; [ -f $HOME/.profile ] && source $HOME/.profile; env" 
        | lines | parse "{n}={v}" 
        | where { |x| not ($x.n in ["_", "LAST_EXIT_CODE", "DIRS_POSITION", "FILE_PWD", "PWD", "CURRENT_FILE", "CMD_START_TIME", "CMD_LAST"]) }
        | transpose --header-row | into record)
    
    # Extract PATH from profile if it exists, and merge it with current PATH
    if ($profile_env.PATH? | is-not-empty) {
        let profile_paths = ($profile_env.PATH | split row (char esep))
        $env.PATH = ($env.PATH | append $profile_paths | uniq)
    }
    
    # Load everything else from the record (excluding PATH which we handled)
    load-env (if ($profile_env | columns | any {|c| $c == "PATH" }) { $profile_env | reject PATH } else { $profile_env })
}

# fnm setup
if (which fnm | is-not-empty) {
    let fnm_env = (fnm env --shell bash
        | lines
        | str replace 'export ' '' | str replace -a '"' ''
        | parse "{n}={v}"
        | where n not-in ["FNM_ARCH", "PATH"]
        | transpose --header-row | into record)
    load-env $fnm_env
    if ($env.FNM_MULTISHELL_PATH? | is-not-empty) {
        $env.PATH = ($env.PATH | prepend [($env.FNM_MULTISHELL_PATH | path join "bin"), $env.FNM_MULTISHELL_PATH])
    }
}

# --- Prompt ---
let is_root = (try { (id -u | str trim) == "0" } catch { false })
let insert_color = if $is_root { "red" } else { "green" }

$env.PROMPT_INDICATOR = $"(ansi $insert_color)λ (ansi reset)"
$env.PROMPT_INDICATOR_VI_INSERT = $"(ansi $insert_color)λ (ansi reset)"
$env.PROMPT_INDICATOR_VI_NORMAL = $"(ansi blue)λ (ansi reset)"
$env.PROMPT_MULTILINE_INDICATOR = $"(ansi yellow)|   (ansi reset)"
$env.PROMPT_COMMAND = {||}
$env.PROMPT_COMMAND_RIGHT = {||}

# --- Main Config ---
$env.config = {
    show_banner: false,
    edit_mode: "vi",
    history: {
        max_size: 1_000_000,
        sync_on_enter: true,
        isolation: true,
        file_format: sqlite,
    }
    hooks: {
        pre_prompt: [{
            # Notify when the previous command took longer than 10s.
            if ($env.CMD_START_TIME? | describe) == "datetime" {
                let duration = (date now) - $env.CMD_START_TIME
                if $duration > 10sec {
                    let cmd = ($env.CMD_LAST? | default "")
                    try {
                        notify-send -i utilities-terminal "Command Finished" $"($cmd)\nDuration: ($duration)"
                    } catch {
                        print $"(ansi yellow)🔔 Command finished in ($duration)(ansi reset)"
                    }
                }
            }
            print "" # Newline before prompt
        }],
        env_change: {
            PWD: [
                { |before, after|
                    # Load .env.nu if it exists (NUON format)
                    let env_nu = ($after | path join ".env.nu")
                    if ($env_nu | path exists) {
                        print $"(ansi cyan)✨ Loading environment from ($env_nu)(ansi reset)"
                        try {
                            load-env (open $env_nu | from nuon)
                        } catch {
                            print $"(ansi red)❌ Error: .env.nu must return a record \(e.g., { FOO: 'BAR' }\)(ansi reset)"
                        }
                    }

                    # Load standard .env file if it exists (POSIX/dotenv format)
                    let env_sh = ($after | path join ".env")
                    if ($env_sh | path exists) {
                        print $"(ansi cyan)✨ Loading environment from ($env_sh)(ansi reset)"
                        try {
                            let parsed = (
                                open -r $env_sh
                                | lines
                                | each {|l| $l | str trim}
                                | where {|l| not ($l | str starts-with '#') and ($l | is-not-empty)}
                                | str replace -r '^export\s+' ''
                                | parse "{key}={val}"
                                | update val { |row| $row.val | str replace -r '^["\x27](.*)["\x27]$' '$1' }
                                | transpose -r -d
                            )
                            load-env $parsed
                        } catch {
                            print $"(ansi red)❌ Error: Failed to parse .env file(ansi reset)"
                        }
                    }
                }
                # Hide old overlay if active
                {
                    condition: {|before, after| 'overlay' in (overlay list | get name) }
                    code: "overlay hide overlay"
                }
                # Hide old .overlay if active
                {
                    condition: {|before, after| '.overlay' in (overlay list | get name) }
                    code: "overlay hide .overlay"
                }
                # Load new overlay if exists in the new directory
                {
                    condition: {|before, after| $after | path join "overlay.nu" | path exists }
                    code: "overlay use overlay.nu"
                }
                # Load new .overlay if exists in the new directory
                {
                    condition: {|before, after| $after | path join ".overlay.nu" | path exists }
                    code: "overlay use .overlay.nu"
                }
            ]
        },
        pre_execution: [{
            $env.CMD_START_TIME = (date now)
            $env.CMD_LAST = $in
        }]
    },
    keybindings: [
        {
            name: "fzf_dir_cd",
            modifier: control, keycode: char_t, mode: [vi_insert, vi_normal],
            event: { send: ExecuteHostCommand, cmd: "let f = (select-folder $env.PWD); if ($f | is-not-empty) { cd $f }" }
        },
        {
            name: "fzf_dir_cd_home",
            modifier: control, keycode: char_h, mode: [vi_insert, vi_normal],
            event: { send: ExecuteHostCommand, cmd: "let f = (select-folder $env.HOME 1); if ($f | is-not-empty) { cd $f }" }
        },
        {
            name: "fzf_dir_cd_dev",
            modifier: control, keycode: char_d, mode: [vi_insert, vi_normal],
            event: { send: ExecuteHostCommand, cmd: "let f = (select-folder ($env.HOME | path join dev) 3); if ($f | is-not-empty) { cd $f }" }
        },
        {
            name: "git_cd_repo_root",
            modifier: control, keycode: char_g, mode: [vi_insert, vi_normal],
            event: { send: ExecuteHostCommand, cmd: "let r = (try { git rev-parse --show-toplevel | str trim } catch { '' }); if ($r | is-not-empty) { cd $r }" }
        },
        {
            name: "nvim_current_dir",
            modifier: control, keycode: char_w, mode: [vi_insert, vi_normal],
            event: { send: ExecuteHostCommand, cmd: "nvim ." }
        },
        {
            name: "nvim_diffview",
            modifier: alt, keycode: char_d, mode: [vi_insert, vi_normal],
            event: { send: ExecuteHostCommand, cmd: "nvim +DiffviewOpen" }
        },
        {
            name: "run_agy",
            modifier: alt, keycode: char_g, mode: [vi_insert, vi_normal, emacs],
            event: { send: ExecuteHostCommand, cmd: "agy" }
        },
        {
            name: paste_bash_as_nushell
            modifier: alt
            keycode: char_v
            mode: [emacs, vi_normal, vi_insert]
            event: {
                send: executehostcommand
                cmd: "
                    let clipboard = (
                        if ($nu.os-info.name == 'windows' or (('/proc/version' | path exists) and (open /proc/version | str contains 'microsoft'))) {
                            powershell.exe -command Get-Clipboard | str trim
                        } else if ($nu.os-info.name == 'macos') {
                            pbpaste | str trim
                        } else {
                            try { wl-paste | str trim } catch { xclip -selection clipboard -o | str trim }
                        }
                    )
                    let converted = ($clipboard
                        | str replace --all --regex '\\\\$' ' '
                        | str replace --all --regex '\\\\\\r?\\n' ' '
                        | str replace --all '&&' ';'
                        | str replace --all --regex '\\s+;\\s+' '; '
                    )
                    commandline edit --replace $converted
                "
            }
        }
        {
            name: "show_status_summary"
            modifier: alt
            keycode: char_s
            mode: [emacs, vi_normal, vi_insert]
            event: {
                send: ExecuteHostCommand
                cmd: "show-status-summary"
            }
        }
    ]
}

# --- Aliases ---
alias o = ollama
alias v = nvim
alias g = git
alias gd = git diff
alias gds = git diff | delta --side-by-side
alias p = docker
alias pc = docker compose
alias d = docker
alias dc = docker compose
alias rg = rg --hidden --glob '!.git'
alias gg = lazygit
alias fg = job unfreeze
alias c = cargo
alias diff = delta
alias n = niri
alias img = viu
alias m = make
alias mk = minikube
alias objdump = bingrep
alias pointer = highlight-pointer -c '#ff6188' -p '#a9dc76' -r 10
alias w = hwatch

# --- Custom Commands ---

# Calculate workday and calendar progress for the current month to compare against usage percentages
def workdays [
    date?: string # Optional date to query (defaults to current time)
] {
    let now = if ($date | is-empty) {
        date now
    } else {
        try {
            $date | into datetime
        } catch {
            error make {msg: $"Invalid date format: '($date)'. Please provide a valid date string (e.g. YYYY-MM-DD)"}
        }
    }
    let year = ($now | format date "%Y" | into int)
    let month_str = ($now | format date "%m")
    let start_of_month = ($now | format date "%Y-%m-01" | into datetime)
    
    # Generate all days in the current month
    let month_days = (0..30 
        | each { |i| $start_of_month + ($i * 1day) } 
        | where { |d| ($d | format date "%m") == $month_str })
        
    let total_calendar_days = ($month_days | length)
    
    # Filter for workdays (Monday to Friday, i.e., %u is 1..5)
    let work_days = ($month_days | where { |d| ($d | format date "%u" | into int) <= 5 })
    let total_workdays = ($work_days | length)
    
    let today_day = ($now | format date "%d" | into int)
    let today_is_workday = (($now | format date "%u" | into int) <= 5)
    
    # Calculate current day fraction (based on local time)
    let hour = ($now | format date "%H" | into int)
    let minute = ($now | format date "%M" | into int)
    let second = ($now | format date "%S" | into int)
    let today_fraction = (($hour * 3600 + $minute * 60 + $second) / 86400.0)
    
    # Completed workdays (days strictly before today)
    let completed_workdays = ($work_days | where { |d| ($d | format date "%d" | into int) < $today_day } | length)
    let elapsed_workdays = ($completed_workdays + (if $today_is_workday { $today_fraction } else { 0.0 }))
    
    # Completed calendar days
    let completed_calendar_days = $today_day - 1
    let elapsed_calendar_days = $completed_calendar_days + $today_fraction
    
    # Percentages (clamped to 0-100 range for display safety)
    let workday_pct_raw = (($elapsed_workdays / $total_workdays) * 100)
    let workday_pct = (if $workday_pct_raw < 0.0 { 0.0 } else if $workday_pct_raw > 100.0 { 100.0 } else { $workday_pct_raw })
    
    let calendar_pct_raw = (($elapsed_calendar_days / $total_calendar_days) * 100)
    let calendar_pct = (if $calendar_pct_raw < 0.0 { 0.0 } else if $calendar_pct_raw > 100.0 { 100.0 } else { $calendar_pct_raw })
    
    # Visual progress bar generator using Catppuccin Mocha colors
    let make_bar = { |pct, color|
        let width = 20
        let filled_raw = (($pct / 100.0) * $width | math round)
        let filled = (if $filled_raw < 0 { 0 } else if $filled_raw > $width { $width } else { $filled_raw })
        let empty = ($width - $filled)
        let fill_str = (0..<$filled | each { "█" } | str join)
        let empty_str = (0..<$empty | each { "░" } | str join)
        $"(ansi -e { fg: $color })($fill_str)(ansi -e { fg: "#6c7086" })($empty_str)(ansi reset)"
    }
    
    [
        {
            "Category": "Work Days",
            "Total": $total_workdays,
            "Elapsed": ($elapsed_workdays | math round --precision 2),
            "Progress": $"($workday_pct | math round --precision 2)%",
            "Visual": (do $make_bar $workday_pct "#89b4fa") # Catppuccin Mocha Blue
        },
        {
            "Category": "Calendar Days",
            "Total": $total_calendar_days,
            "Elapsed": ($elapsed_calendar_days | math round --precision 2),
            "Progress": $"($calendar_pct | math round --precision 2)%",
            "Visual": (do $make_bar $calendar_pct "#cba6f7") # Catppuccin Mocha Mauve
        }
    ]
}

# Run Ollama on the CUDA instance (2080 Ti, port 11435)
def oc [...args: string] {
    with-env { OLLAMA_HOST: "127.0.0.1:11435" } {
        ^ollama ...$args
    }
}

# Create and switch to a new git worktree
def --env "gw" [name?: string, --base: string = "main"] {
    let repo_root = try { git rev-parse --show-toplevel | str trim } catch {
        print-error "Not in a git repository"
        return
    }
    let name = if ($name | is-empty) { input "Worktree name (branch)> " } else { $name }
    if ($name | is-empty) { return }
    let target = ($repo_root | path dirname | path join $"(($repo_root | path basename))-worktrees" | path join $name)
    print-info $"Creating worktree at ($target)..."
    git worktree add -b $name $target $base
    cd $target
}

# Sandbox toggles
def --env "sandbox enable" [] {
    $env.GEMINI_SANDBOX = "docker"
    print "Gemini sandbox enabled."
}

def --env "sandbox disable" [] {
    hide-env GEMINI_SANDBOX
    hide-env SANDBOX_FLAGS
    print "Gemini sandbox disabled."
}

# Source local completions
source fj-completions.nu
use completions *

# --- Marshian Galaxy Maintenance ---
# Updates all family servers (k8s nodes, storage, wireguard)
def update-marshian-galaxy [] {
    let hosts = [
        "k8s0", "k8s1", "k8s2", "k8s3", "k8s4",
        "srv2",
        "wireguard",
        "pihole"
    ]
    
    print $"(ansi green)👽 Initiating Marshian Galaxy Update Protocol... (ansi reset)"
    
    # Check for latest Alpine version
    print $"(ansi cyan)📡 Checking for latest Alpine release... (ansi reset)"
    let latest_alpine = (try {
        let release_json = (http get https://alpinelinux.org/releases.json)
        let branch = ($release_json | get latest_stable)
        $release_json | get release_branches | where rel_branch == $branch | get releases | flatten | first | get version
    } catch { 
        "unknown" 
    })

    if $latest_alpine != "unknown" {
        print $"(ansi green)Current stable branch latest version: ($latest_alpine)(ansi reset)"
    } else {
        print $"(ansi yellow)⚠️ Could not fetch latest Alpine version info.(ansi reset)"
    }

    for host in $hosts {
        # Check OS and Version in one shot
        let os_report = (ssh $host "sh -c 'if [ -f /etc/alpine-release ]; then printf \"Alpine \"; cat /etc/alpine-release; elif [ -f /etc/arch-release ]; then printf \"Arch Linux\"; elif [ -f /etc/debian_version ]; then printf \"Debian \"; cat /etc/debian_version; else printf \"Unknown\"; fi'" | str trim)
        
        print $"\n(ansi blue)🚀 Updating Outpost: ($host) [($os_report)](ansi reset)"
        
        if ($os_report | str contains "Alpine") {
            ssh $host "doas apk update; doas apk upgrade"
        } else if ($os_report | str contains "Arch") {
            ssh $host "sudo pacman -Syu --noconfirm"
        } else if ($os_report | str contains "Debian") {
            ssh $host "sudo apt update; sudo apt upgrade -y"
            if $host == "pihole" {
                print $"(ansi cyan)🕳️ Updating Pi-hole on ($host)...(ansi reset)"
                ssh $host "sudo pihole -up"
            }
        }
    }
    
    print $"\n(ansi green)✨ All Outposts secured. The Galaxy is up to date! 🪐(ansi reset)"
}

# Safely reboot all family servers and K8s nodes
def reboot-marshian-galaxy [] {
    let script = ($env.HOME | path join "dev/dotfiles/helpers/reboot-galaxy.nu")
    nu $script
}

# Set up Nushell configuration symlinks for the root user
def setup-root-config [] {
    let sudo_cmd = if (which doas | is-not-empty) { "doas" } else { "sudo" }
    let dotfiles_dir = ($env.HOME | path join "dev/dotfiles")
    let root_config_dir = "/root/.config/nushell"
    
    print-info $"Creating root configuration directory via ($sudo_cmd)..."
    run-external $sudo_cmd "mkdir" "-p" $root_config_dir
    
    let files = [
        "config.nu",
        "env.nu",
        "local.nu",
        "linux.nu",
        "macos.nu",
        "windows.nu",
        "fj-completions.nu",
        "modules"
    ]
    
    for f in $files {
        let src = ($dotfiles_dir | path join "nushell" $f)
        if ($src | path exists) {
            let dest = ($root_config_dir | path join $f)
            print-info $"Symlinking ($f) -> ($dest) via ($sudo_cmd)..."
            run-external $sudo_cmd "ln" "-sf" $src $dest
        }
    }
    
    print-info "Root Nushell configuration setup complete!"
}
