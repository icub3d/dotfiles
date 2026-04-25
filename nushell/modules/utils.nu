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
export def "select-folder" [path: path, depth = 0] {
  let cmd = if $depth == 0 { ["fd" "--type" "d" "--strip-cwd-prefix"] } else { ["fd" "--type" "d" "--strip-cwd-prefix" "--max-depth" $"($depth)"] }
  let selected = (do { ^$cmd --base-directory $path } | fzf --reverse --border=rounded --prompt "path> " | str trim)
  if ($selected | is-empty) { "" } else { $path | path join $selected }
}
