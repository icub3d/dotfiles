# Utility Module

# A helper to print messages in a consistent style
export def "print-info" [message: string] { print $"✅ ($message)" }
export def "print-error" [message: string] { print -e $"❌ ERROR: ($message)" }

# Clear the terminal and scrollback
export def "reset-terminal" [] {
      print -n "\u{001b}c\u{001b}[3J\u{001b}[H\u{001b}[2J\u{001b}[0m"
}

# Normalize and convert a debug-formatted Rust Duration string
export def "parse-duration" [value: string] {
      $value
      | str trim
      | split row " "
      | where { |part| not ($part | str trim | is-empty) }
      | each { |part|
          let normalized = (
              if ($part | str ends-with "ms") { $part }
              else if ($part | str ends-with "us") { $part | str replace "us" "µs" }
              else if ($part | str ends-with "s") { $part | str replace --regex "s$" "sec" }
              else if ($part | str ends-with "m") { $part | str replace --regex "m$" "min" }
              else if ($part | str ends-with "h") { $part | str replace --regex "h$" "hr" }
              else { $part }
          )
          try { $normalized | into duration } catch { 0ns }
      }
      | math sum
}

# Parse INI configuration files
export def "parse ini" [ path?: path ] {
    let content = if ($path | is-empty) { $in | into string | lines } else { open $path | lines }
    $content
    | where $it != "" and not ($it | str starts-with "#")
    | reduce -f { current_section: "default", data: {} } {|line, acc|
        if $line =~ '^\[.*\]$' {
            let section = ($line | str replace -a -r '\[|\]' '')
            { current_section: $section, data: ($acc.data | upsert $section {}) }
        } else if $line =~ '[:=]' {
            let parts = ($line | split column -n 2 -r '[:=]')
            let key = ($parts.0.column0 | str trim)
            let val = ($parts.0.column1 | str trim)
            let current = ($acc.data | get -o $acc.current_section | default {})
            { current_section: $acc.current_section, data: ($acc.data | upsert $acc.current_section ($current | upsert $key $val)) }
        } else { $acc }
    } | get data
}

# Decode JWT section
export def "decode-jwt-section" [] {
    tr '_-' '/+' | base64 -i -d err> /dev/null | from json
}

# Convert unix timestamp
export def "dt unix" [
    --nano (-n)
    --zone (-z) = "l"
    timestamp: string
] {
    let ts = if $nano { $timestamp | into int } else { ($timestamp | into int) * 1_000_000_000 }
    $ts | into datetime -z $zone | format date "%+"
}

# FZF Folder Selector
export def "select-folder" [path: path, depth: int = 0] {
    let depth_args = if $depth == 0 { [] } else { ["--max-depth" ($depth | into string)] }
    let selected = (
      fd --type d --strip-cwd-prefix --base-directory $path ...$depth_args
      | fzf --reverse --border=rounded --prompt "path> "
      | str trim
    )
    if ($selected | is-empty) { "" } else { $path | path join $selected }
}

# Find and open a project in Neovim
export def fp [] {
      let dev_dir = ($nu.home-dir | path join "dev")
      let project = (
          fd --type d --hidden --exclude .git --max-depth 4 . $dev_dir
          | fzf --prompt="🚀 Project> " --border=rounded
          | str trim
      )
      if ($project | is-not-empty) {
          cd $project
          nvim .
      }
}

# Browse git diffs interactively (VS Code style)
export def vd [] {
      try { git rev-parse --is-inside-work-tree | ignore } catch {
          print-error "Not in a git repository"
          return
      }

      let selected = (
          git status --porcelain
          | fzf --prompt="🔍 Nav> "
                --header " [/] Search  [Esc] Nav  [Enter] Edit"
                --preview "git diff --color=always -- (echo {} | cut -c4-) | delta --side-by-side --width ($env.COLUMNS? | default 120)"
                --preview-window "right:70%"
                --bind "j:down,k:up,l:preview-down,h:preview-up,ctrl-f:preview-page-down,ctrl-b:preview-page-up,{:preview-page-up,}:preview-page-down"
                --bind "/:unbind(j,k,h,l,{,})+change-prompt(🔍 Search> )"
                --bind "ctrl-s:unbind(j,k,h,l,{,})+change-prompt(🔍 Search> )"
                --bind "esc:rebind(j,k,h,l,{,})+change-prompt(🔍 Nav> )"
                --bind "ctrl-n:rebind(j,k,h,l,{,})+change-prompt(🔍 Nav> )"
                --border=rounded
          | str trim
      )

      if ($selected | is-not-empty) {
          # Skip the 3-char porcelain status prefix.
          nvim ($selected | str substring 3..)
      }
}
