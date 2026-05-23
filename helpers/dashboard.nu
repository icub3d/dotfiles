#!/usr/bin/env nu

# A custom, beautiful Catppuccin Mocha-themed Homelab SSH Dashboard for the Marshian Galaxy.
# Optimized to query remote Nushell environments natively.

# Define hosts grouped by category (from reboot-galaxy.nu)
const workers = ["k8s4", "k8s3"]
const control_planes = ["k8s2", "k8s1", "k8s0"]
const generic_alpine = ["srv2", "wireguard"]
const generic_debian = ["pihole"]

const all_hosts = ["k8s4", "k8s3", "k8s2", "k8s1", "k8s0", "srv2", "wireguard", "pihole"]

# Catppuccin Mocha Colors (ANSI Codes)
const color_mauve = (ansi { fg: '#cba6f7' })
const color_blue = (ansi { fg: '#89b4fa' })
const color_teal = (ansi { fg: '#94e2d5' })
const color_flamingo = (ansi { fg: '#f2cdcd' })
const color_green = (ansi { fg: '#a6e3a1' })
const color_yellow = (ansi { fg: '#f9e2af' })
const color_red = (ansi { fg: '#f38ba8' })
const color_surface1 = (ansi { fg: '#585b70' })
const color_overlay1 = (ansi { fg: '#7f849c' })
const color_reset = (ansi reset)

# Helper to create a premium progress bar with aligned percentage
def make-progress-bar [used: int, total: int, width: int = 10] {
    if $total == 0 { return "N/A" }
    let pct = ($used / $total)
    let filled_chars = ([$width (($pct * $width) | into int)] | math min | [$in 0] | math max)
    let empty_chars = ($width - $filled_chars)
    
    let color = if $pct < 0.7 { $color_green } else if $pct < 0.9 { $color_yellow } else { $color_red }
    let pct_str = (($pct * 100) | math round | into string | fill -a right -c " " -w 3)
    let filled_str = ("" | fill -c "█" -w $filled_chars)
    let empty_str = ("" | fill -c "░" -w $empty_chars)
    let bar = ($color + $filled_str + $color_surface1 + $empty_str + $color_reset + " " + $pct_str + "%")
    $bar
}

# Fetch stats from a host over SSH
def fetch-host-metrics [host: string, type: string] {
    # Query system details, CPU load, and core count natively using remote Nushell!
    let cmd = "let cpu_info = (sys cpu); let cpu_count = ($cpu_info | length); let cpu = ($cpu_info | first | get load_average | split row ', ' | first | into float); let mem = (sys mem); let root_disk = (sys disks | where mount == '/' | first); let data_disk = (sys disks | where mount == '/data'); let has_data = ($data_disk | is-not-empty); let data_btrfs = (if $has_data { ($data_disk | first | get type) == 'btrfs' } else { false }); let data_used = (if $has_data { if $data_btrfs { let usage = (try { btrfs filesystem usage /data | lines } catch { [] }); if ($usage | is-not-empty) { let dev_size = ($usage | where ($it | str contains 'Device size:') | first | split row -r '\\s+' | get 3 | into filesize); let free_est = ($usage | where ($it | str contains 'Free (estimated):') | first | split row -r '\\s+' | get 3 | into filesize); let data_ratio = ($usage | where ($it | str contains 'Data ratio:') | first | split row -r '\\s+' | get 3 | into float); let total = ($dev_size / $data_ratio); let free = $free_est; (($total - $free) / 1mib | into int) } else { (($data_disk | first | get total) - ($data_disk | first | get free)) / 1mib | into int } } else { (($data_disk | first | get total) - ($data_disk | first | get free)) / 1mib | into int } } else { 0 }); let data_total = (if $has_data { if $data_btrfs { let usage = (try { btrfs filesystem usage /data | lines } catch { [] }); if ($usage | is-not-empty) { let dev_size = ($usage | where ($it | str contains 'Device size:') | first | split row -r '\\s+' | get 3 | into filesize); let data_ratio = ($usage | where ($it | str contains 'Data ratio:') | first | split row -r '\\s+' | get 3 | into float); (($dev_size / $data_ratio) / 1mib | into int) } else { ($data_disk | first | get total) / 1mib | into int } } else { ($data_disk | first | get total) / 1mib | into int } } else { 0 }); { load: $cpu, cores: $cpu_count, mem_used: ($mem.used / 1mib | into int), mem_total: ($mem.total / 1mib | into int), disk_used: (($root_disk.total - $root_disk.free) / 1mib | into int), disk_total: ($root_disk.total / 1mib | into int), has_data: $has_data, data_used: $data_used, data_total: $data_total } | to json -r"
    
    let result = (do { ssh -o ConnectTimeout=2 -o BatchMode=yes $host $cmd } | complete)
    
    if $result.exit_code != 0 {
        return {
            Host: $host
            Type: $type
            🟢: "🔴"
            Load: "N/A"
            Memory: "N/A"
            Disk: "N/A"
            has_data: false
            data_used: 0
            data_total: 0
        }
    }
    
    let raw = ($result.stdout | str trim)
    let parsed = (try {
        $raw | from json
    } catch {
        null
    })
    
    if $parsed == null or ($parsed | is-empty) {
        return {
            Host: $host
            Type: $type
            🟢: "⚠️"
            Load: "N/A"
            Memory: "N/A"
            Disk: "N/A"
            has_data: false
            data_used: 0
            data_total: 0
        }
    }
    
    let load = ($parsed.load | into float)
    let cores = ($parsed.cores | into int)
    let mem_used = ($parsed.mem_used | into int)
    let mem_total = ($parsed.mem_total | into int)
    let disk_used = ($parsed.disk_used | into int)
    let disk_total = ($parsed.disk_total | into int)
    
    # Intelligently color load based on core capacity (under 70% capacity = green, under 100% = yellow, over = red)
    let load_color = if $load < ($cores * 0.7) { $color_green } else if $load < $cores { $color_yellow } else { $color_red }
    let load_str = $"($load_color)($load) / ($cores)($color_reset)"
    
    let mem_bar = (make-progress-bar $mem_used $mem_total)
    let bar_root = (make-progress-bar $disk_used $disk_total)
    
    {
        Host: $host
        Type: $type
        🟢: "🟢"
        Load: $load_str
        Memory: $mem_bar
        Disk: $bar_root
        # Extra fields for storage table
        has_data: $parsed.has_data
        data_used: $parsed.data_used
        data_total: $parsed.data_total
    }
}

export def main [] {
    print "🪐 Initializing Homelab TUI Dashboard..."
    loop {
        # Fetch metrics for all hosts in parallel
        let data = (
            $all_hosts
            | par-each { |host|
                let type = if ($host in $workers) {
                    $"($color_blue)Worker($color_reset)"
                } else if ($host in $control_planes) {
                    $"($color_mauve)CP($color_reset)"
                } else if ($host in $generic_alpine) {
                    $"($color_teal)Alpine($color_reset)"
                } else {
                    $"($color_flamingo)Debian($color_reset)"
                }
                fetch-host-metrics $host $type
            }
        )
        
        # Clear screen
        clear
        
        # 1. Main Hosts Table Header
        print $"($color_mauve)🪐 MARSHIAN GALAXY HOMELAB DASHBOARD ($color_surface1)-----------------------------------($color_reset)\n"
        
        # Print beautiful Nushell table, sorted alphabetically by Host
        let main_table = ($data | sort-by Host | select Host Type 🟢 Load Memory Disk)
        print ($main_table | table)
        
        # 2. Specialized Services Table Header
        print $"\n($color_mauve)🛠️  CLUSTER & SPECIALIZED SERVICES ($color_surface1)---------------------------------------($color_reset)\n"
        
        # NFS Storage Row from srv2
        let srv2_rec = ($data | where Host == "srv2" | first)
        let nfs_row = if ($srv2_rec.🟢 == "🟢" and $srv2_rec.has_data == true) {
            let used_tib = (($srv2_rec.data_used / 1048576) | math round --precision 2 | into string)
            let total_tib = (($srv2_rec.data_total / 1048576) | math round --precision 2 | into string)
            let bar = (make-progress-bar $srv2_rec.data_used $srv2_rec.data_total 8)
            
            {
                "Service / Cluster Resource": "NFS Storage (srv2 /data)"
                "Status / Health": "🟢"
                "Details & Utilization": $"($used_tib) / ($total_tib) TiB  ($bar)"
            }
        } else {
            let status = if $srv2_rec.🟢 == "🟢" { "⚠️ Mount Missing" } else { "🔴 Offline" }
            {
                "Service / Cluster Resource": "NFS Storage (srv2 /data)"
                "Status / Health": $status
                "Details & Utilization": "N/A"
            }
        }

        # K8s Rows
        let k8s_rows = try {
            let nodes_raw = (kubectl get nodes -o json | from json | get items)
            let total_nodes = ($nodes_raw | length)
            let ready_nodes = ($nodes_raw | get status.conditions | each { |cond| $cond | where type == "Ready" | first } | where status == "True" | length)
            
            let pods_raw = (kubectl get pods -A -o json | from json | get items)
            let total_pods = ($pods_raw | length)
            let unhealthy_pods = ($pods_raw | where { |it| $it.status.phase != "Running" and $it.status.phase != "Succeeded" } | length)
            
            let restarts = (try {
                $pods_raw | get status.containerStatuses | flatten | get restartCount | math sum
            } catch {
                0
            })
            
            let node_status = if $ready_nodes == $total_nodes { "🟢" } else { "🟡" }
            let pod_status = if $unhealthy_pods == 0 { "🟢" } else { "🔴" }
            
            [
                {
                    "Service / Cluster Resource": "K8s Cluster Nodes"
                    "Status / Health": $"($node_status) ($ready_nodes) / ($total_nodes) Ready"
                    "Details & Utilization": "Physical cluster nodes online"
                }
                {
                    "Service / Cluster Resource": "K8s Cluster Pods"
                    "Status / Health": $"($pod_status) ($unhealthy_pods) Unhealthy"
                    "Details & Utilization": $"($total_pods) Active  |  ($restarts) Restarts"
                }
            ]
        } catch {
            [
                {
                    "Service / Cluster Resource": "K8s Cluster Nodes"
                    "Status / Health": "🔴 Unreachable"
                    "Details & Utilization": "Could not contact Kubernetes API"
                }
                {
                    "Service / Cluster Resource": "K8s Cluster Pods"
                    "Status / Health": "🔴 Unreachable"
                    "Details & Utilization": "Could not retrieve Pod status"
                }
            ]
        }

        let secondary_table = ([$nfs_row] | append $k8s_rows)
        print ($secondary_table | table)
        
        print $"\n($color_overlay1)Refreshes every 30 seconds. Press Ctrl+C to exit.($color_reset)"
        sleep 30sec
    }
}
