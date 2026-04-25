# Competitive Programming Helper Module

# Find a Rust file based on search patterns
def "find-file" [...patterns: string] {
    if ($patterns | is-empty) {
        let files = (fd --type f --extension rs | lines)
        if ($files | is-empty) {
            return null
        }
        return ($files | first)
    }
    
    let all_files = (fd --type f --extension rs | lines)
    let matching_files = ($all_files | where {|file|
        $patterns | all {|pattern| $file | str contains -i $pattern }
    })
    
    if ($matching_files | is-empty) {
        return null
    }
    
    $matching_files | first
}

# Get cargo package name from a file path
def "get-package" [file: string] {
    let file_path = ($file | path expand)
    let dir = ($file_path | path dirname)
    
    mut current = $dir
    mut found_cargo = ""
    
    loop {
        let cargo_toml = ($current | path join "Cargo.toml")
        if ($cargo_toml | path exists) {
            $found_cargo = $cargo_toml
            break
        }
        
        let parent = ($current | path dirname)
        if $parent == $current { break }
        $current = $parent
    }
    
    if ($found_cargo | is-empty) {
        return {package: null, needs_flag: false}
    }
    
    let pkg_dir = ($found_cargo | path dirname)
    mut search_dir = ($pkg_dir | path dirname)
    
    loop {
        let potential_workspace = ($search_dir | path join "Cargo.toml")
        if ($potential_workspace | path exists) and ($potential_workspace != $found_cargo) {
            let workspace_content = (open $potential_workspace)
            if ($workspace_content | get -o workspace | is-not-empty) {
                let package_name = (open $found_cargo | get package.name)
                return {package: $package_name, needs_flag: true}
            }
        }
        
        let parent = ($search_dir | path dirname)
        if $parent == $search_dir { break }
        $search_dir = $parent
    }
    
    return {package: null, needs_flag: false}
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
    let test_run = (do -i { ^$test_cmd } | complete)
    let test_lines = ($test_run.stdout | default "" | lines | where {|it| $it | str starts-with "test " })
    
    let run_cmd = (build-cmd $file "run" "--release" "-q")
    let run_output = (do -i { ^$run_cmd } | complete)
    
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
            let target_result = (do -i { nu helper.nu get-target ...$helper_args } | complete)
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
