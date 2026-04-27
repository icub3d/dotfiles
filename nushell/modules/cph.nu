# Competitive Programming Helper Module

# Find a Rust file matching all patterns (case-insensitive substring), or any if none given.
def "find-file" [...patterns: string] {
    fd --type f --extension rs
    | lines
    | where { |file| $patterns | all { |pat| $file | str contains -i $pat } }
    | first
}

# Walk up from $start looking for $filename. Returns the path or null.
def find-up [filename: string, start: path] {
    mut dir = ($start | path expand)
    loop {
        let candidate = ($dir | path join $filename)
        if ($candidate | path exists) { return $candidate }
        let parent = ($dir | path dirname)
        if $parent == $dir { return null }
        $dir = $parent
    }
}

# Get cargo package name from a file path
def "get-package" [file: string] {
    let cargo_toml = (find-up "Cargo.toml" ($file | path expand | path dirname))
    if $cargo_toml == null { return {package: null, needs_flag: false} }

    let pkg_dir = ($cargo_toml | path dirname)
    let workspace_toml = (find-up "Cargo.toml" ($pkg_dir | path dirname))
    if $workspace_toml == null or $workspace_toml == $cargo_toml {
        return {package: null, needs_flag: false}
    }

    if (open $workspace_toml | get -o workspace | is-not-empty) {
        return {package: (open $cargo_toml | get package.name), needs_flag: true}
    }

    {package: null, needs_flag: false}
}

# Build cargo command for a file
def "build-cmd" [file: string, cmd: string, ...extra_args: string] {
    let pkg_info = (get-package $file)
    let bin_name = ($file | path parse | get stem)
    
    mut cargo_cmd = ["cargo" $cmd]
    if $pkg_info.needs_flag {
        $cargo_cmd = ($cargo_cmd | append ["-p" $pkg_info.package])
    }
    
    $cargo_cmd | append ["--bin" $bin_name] | append $extra_args
}

# Run a competitive programming solution with summary
def "run-with-summary" [file: string] {
    let bin_name = ($file | path parse | get stem)
    let pkg_info = (get-package $file)
    let workspace_name = if $pkg_info.needs_flag { $pkg_info.package } else { "" }
    
    let test_cmd = (build-cmd $file "test" "--release" "--no-fail-fast")
    let test_run = (^$test_cmd | complete)
    let test_lines = ($test_run.stdout | default "" | lines | where {|it| $it | str starts-with "test " })

    let run_cmd = (build-cmd $file "run" "--release" "-q")
    let run_output = (^$run_cmd | complete)
    
    let part_outputs = (
        $run_output.stdout 
        | default "" 
        | lines 
        | where { |l| $l | str starts-with "p" } 
        | each { |line|
            let parts = ($line | split row -r '\s+')
            if ($parts | length) >= 3 {
                { part: ($parts.0), time: ($parts.1), solution: ($parts.2) }
            } else { null }
        }
        | compact
    )
    
    if ($part_outputs | is-empty) {
        print $run_output.stdout
        return
    }
    
    let has_helper = ("helper.nu" | path exists)
    
    mut results = []
    for part_output in $part_outputs {
        let part_no = $part_output.part
        let part_test_lines = ($test_lines | where {|it| $it | str contains $"test_($part_no)" })
        
        let test_status = if ($part_test_lines | is-empty) { "❓" } 
                         else if ($part_test_lines | all { |it| $it | str contains "ok" }) { "✅" } 
                         else { "❌" }
        
        mut target = ""
        mut answer_status = "🔄"
        
        if $has_helper {
            let helper_args = if ($workspace_name | is-empty) { [$bin_name $part_no] } else { [$workspace_name $bin_name $part_no] }
            let target_result = (nu helper.nu get-target ...$helper_args | complete)
            if $target_result.exit_code == 0 {
                $target = ($target_result.stdout | str trim)
                $answer_status = if ($target | is-empty) { "🔄" } else if $part_output.solution == $target { "✅" } else { "❌" }
            }
        }
        
        $results = ($results | append {
            "🧩": $part_no, "🧪": $test_status, "🚦": $answer_status, "⏰": $part_output.time, "💡": $part_output.solution, "🎯": $target
        })
    }
    
    $results | table -i false
}

# --- Exported Commands ---

# Run a competitive programming solution
export def run [...patterns: string] {
    let file = (find-file ...$patterns)
    if $file == null { return }
    let cmd = (build-cmd $file "run" "--release" "-q")
    ^$cmd
}

# Test a competitive programming solution
export def test [...patterns: string] {
    let file = (find-file ...$patterns)
    if $file == null { return }
    let cmd = (build-cmd $file "test" "--release" "--no-fail-fast" "--" "--nocapture")
    ^$cmd
}

# Watch and run a competitive programming solution
export def watch-run [...patterns: string, --test] {
    let file = (find-file ...$patterns)
    if $file == null { return }
    
    let block = {
        print -n "\u{001b}c\u{001b}[3J\u{001b}[H\u{001b}[2J"
        if $test { test ...$patterns } else {
            try { run-with-summary $file } catch { |err| print $"Compilation failed: ($err.msg)" }
        }
    }
    
    do $block
    watch . --glob="**/*.rs" $block
}

# Debug a competitive programming solution
export def debug [...patterns: string] {
    let file = (find-file ...$patterns)
    if $file == null { return }
    print "🧪 Tests 🧪"
    try { test ...$patterns }
    print "🚀 Solution 🚀"
    try { run ...$patterns }
}

# Create a new competitive programming solution from template
export def new [...args: string] {
    let template = (fd --type f --glob "**/template.rs" | lines | first)
    if ($args | length) == 0 { return }
    
    let name = $args | last
    let workspace = if ($args | length) > 1 { $args.0 } else { "" }
    
    let target_dir = if ($workspace | is-empty) { "src/bin" } else { 
        (fd --type d --glob $"**/*($workspace)*" | lines | where { |d| $d | path join "src/bin" | path exists } | first | path join "src/bin")
    }
    
    let target_file = ($target_dir | path join $"($name).rs")
    open $template | str replace -a "[NAME]" $name | str replace -a "[WORKSPACE]" $workspace | save $target_file
    print $"Created: ($target_file)"
}

# Watch and debug a competitive programming solution
export def watch-run-debug [...patterns: string] {
    let file = (find-file ...$patterns)
    if $file == null { return }
    
    let block = {
        debug ...$patterns
    }
    
    do $block
    watch . --glob="**/*.rs" $block
}

# --- Aliases ---
export alias r = run
export alias t = test
export alias w = watch-run
export alias d = debug
export alias wd = watch-run-debug
export alias n = new
