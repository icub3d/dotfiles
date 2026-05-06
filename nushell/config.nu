# --- Modules ---
use modules/utils.nu *
use modules/system.nu *
use modules/kubernetes.nu *
use modules/media.nu *
# cph is namespaced (cph run, cph test, ...) to avoid clashing with the
# top-level `d`, `n`, `w` aliases below.
use modules/cph.nu

# --- Secrets & Integration ---
const secrets_path = ($nu.default-config-dir | path join ".env.nu")
if ($secrets_path | path exists) { source $secrets_path }

$env.config.shell_integration.osc133 = ($nu.os-info.name != "windows")
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
            # Notify when the previous command took longer than 10s.
            if ($env.CMD_START_TIME? | is-not-empty) {
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
            event: { send: ExecuteHostCommand, cmd: "let f = (select-folder $env.HOME 3); if ($f | is-not-empty) { cd $f }" }
        },
        {
            name: "fzf_dir_cd_dev",
            modifier: control, keycode: char_d, mode: [vi_insert, vi_normal],
            event: { send: ExecuteHostCommand, cmd: "let f = (select-folder ($env.HOME | path join dev) 3); if ($f | is-not-empty) { cd $f }" }
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
alias o = ollama
alias v = nvim
alias g = git
alias gd = git diff
alias gds = git diff | delta --side-by-side
alias p = podman
alias pc = podman compose
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
    $env.GEMINI_SANDBOX = "podman"
    $env.SANDBOX_FLAGS = "--userns=keep-id"
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
