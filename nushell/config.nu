# --- Modules ---
use modules/utils.nu *
use modules/system.nu *
use modules/kubernetes.nu *
use modules/media.nu *
use modules/cph.nu *

# --- Secrets & Integration ---
const secrets_path = ($nu.default-config-dir | path join ".env.nu")
if ($secrets_path | path exists) { source $secrets_path }

# Windows Specifics
if ($nu.os-info.name == "windows") {
  $env.config.shell_integration.osc133 = false
}

$env.config.shell_integration.osc133 = true
$env.config.shell_integration.osc2 = true
$env.config.shell_integration.osc7 = true

# Load environment from system profiles (Linux only)
if ($nu.os-info.name == "linux") {
    let profile_env = (bash -c "[ -f /etc/profile ] && source /etc/profile; [ -f $HOME/.profile ] && source $HOME/.profile; env" 
        | lines | parse "{n}={v}" 
        | where { |x| not ($x.n in ["_", "LAST_EXIT_CODE", "DIRS_POSITION", "FILE_PWD", "PWD", "CURRENT_FILE"]) }
        | transpose --header-row | into record)
    
    # Extract PATH from profile if it exists, and merge it with current PATH
    if ($profile_env.PATH? | is-not-empty) {
        let profile_paths = ($profile_env.PATH | split row (char esep))
        $env.PATH = ($env.PATH | append $profile_paths | uniq)
    }
    
    # Load everything else from the record (excluding PATH which we handled)
    load-env ($profile_env | reject -o PATH)
}

# fnm setup
if (which fnm | is-not-empty) {
    let fnm_env = (fnm env --shell bash | lines | str replace 'export ' '' | str replace -a '"' '' 
        | split column "=" name value | where name not-in ["FNM_ARCH", "PATH"] 
        | reduce -f {} { |it, acc| $acc | upsert $it.name $it.value })
    load-env $fnm_env
    if ($env.FNM_MULTISHELL_PATH? | is-not-empty) {
        $env.PATH = ($env.PATH | prepend [($env.FNM_MULTISHELL_PATH | path join "bin"), $env.FNM_MULTISHELL_PATH])
    }
}

# --- Prompt ---
$env.PROMPT_INDICATOR = $"(ansi green)λ (ansi reset)"
$env.PROMPT_INDICATOR_VI_INSERT = $"(ansi green)λ (ansi reset)"
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
            print "" # Newline before command
            let file_info = $"7;file://($env.HOSTNAME)($env.PWD)"
            ansi --osc $file_info
        }],
        env_change: {
            PWD: [
                { |before, after|
                    let env_file = ($after | path join ".env.nu")
                    if ($env_file | path exists) {
                        print $"(ansi cyan)✨ Loading environment from ($env_file)(ansi reset)"
                        try {
                            # This works if .env.nu returns a record, e.g., { FOO: "BAR" }
                            load-env (open $env_file)
                        } catch {
                            print $"(ansi red)❌ Error: .env.nu must return a record (e.g., { FOO: 'BAR' })(ansi reset)"
                        }
                    }
                }
            ]
        },
        pre_execution: [
            { $env.CMD_START_TIME = (date now) }
        ],
        display_output: {
            let it = $in
            if ($env.CMD_START_TIME? | is-not-empty) {
                let duration = (date now) - $env.CMD_START_TIME
                if $duration > 10sec {
                    let cmd = (history | last 1 | get 0.command)
                    try {
                        notify-send -i utilities-terminal "Command Finished" $"($cmd)\nDuration: ($duration)"
                    } catch {
                        print $"(ansi yellow)🔔 Command finished in ($duration)(ansi reset)"
                    }
                }
            }
            
            # Display the output
            let meta = (metadata $it)
            if ($meta | is-empty) {
                $it
            } else {
                $it | table
            }
        }
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
            event: { send: ExecuteHostCommand, cmd: "let f = (select-folder $nu.home-dir 3); if ($f | is-not-empty) { cd $f }" }
        },
        {
            name: "fzf_dir_cd_dev",
            modifier: control, keycode: char_d, mode: [vi_insert, vi_normal],
            event: { send: ExecuteHostCommand, cmd: "let f = (select-folder ($nu.home-dir | path join dev) 3); if ($f | is-not-empty) { cd $f }" }
        },
        {
            name: "nvim_current_dir",
            modifier: control, keycode: char_w, mode: [vi_insert, vi_normal],
            event: { send: ExecuteHostCommand, cmd: "nvim ." }
        },
        {
            name: "run_gemini",
            modifier: alt, keycode: char_g, mode: [vi_insert, vi_normal, emacs],
            event: { send: ExecuteHostCommand, cmd: "gemini" }
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
    ]
}

# --- Aliases ---
alias v = nvim
alias vd = vd
alias g = git
alias gd = git diff
alias gds = git diff | delta --side-by-side
alias cat = bat
alias p = podman
alias pc = podman compose
alias d = docker
alias dc = docker compose
alias du = dust
alias rg = rg --hidden --glob '!.git'
alias gg = lazygit
alias l = ls
alias ll = ls -l
alias la = ls -a
alias lla = ls -la
alias fg = job unfreeze
alias bench = hyperfine
alias c = cargo
alias diff = delta
alias grep = rg
alias n = niri
alias hexdump = hx
alias iftop = bandwhich
alias img = viu
alias less = bat
alias m = make
alias mk = minikube
alias objdump = bingrep
alias ping = prettyping
alias pointer = highlight-pointer -c '#ff6188' -p '#a9dc76' -r 10
alias w = viddy

# --- Custom Commands ---

# Create and switch to a new git worktree
def --env "gw" [name?: string, --base: string = "main"] {
    let repo_root = (do -i { git rev-parse --show-toplevel } | complete | get stdout | str trim)
    if ($repo_root | is-empty) { print-error "Not in a git repository"; return }
    let name = if ($name | is-empty) { input "Worktree name (branch)> " } else { $name }
    if ($name | is-empty) { return }
    let target = ($repo_root | path dirname | path join $"(($repo_root | path basename))-worktrees" | path join $name)
    print-info $"Creating worktree at ($target)..."
    git worktree add -b $name $target $base
    cd $target
}

# Sandbox toggles
def --env "sandbox enable" [] {
    load-env { GEMINI_SANDBOX: "podman", SANDBOX_FLAGS: "--userns=keep-id" }
    print "Gemini sandbox enabled."
}

def --env "sandbox disable" [] {
    hide-env GEMINI_SANDBOX; hide-env SANDBOX_FLAGS
    print "Gemini sandbox disabled."
}

# Source local completions
source fj-completions.nu
use completions *
