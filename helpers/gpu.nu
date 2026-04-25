#!/usr/bin/env nu

# GPU Helper: Monitor and Manage multi-GPU setup.

# Get stats for all GPUs (AMD and NVIDIA)
export def stats [] {
    let cyan = (ansi cyan_bold)
    let green = (ansi green_bold)
    let yellow = (ansi yellow_bold)
    let reset = (ansi reset)

    print $"($cyan)--- AMD GPU 7900 XTX ---($reset)"
    let amd_perf = (cat /sys/class/drm/card1/device/power_dpm_force_performance_level | str trim)
    let amd_sclk = (cat /sys/class/drm/card1/device/pp_dpm_sclk | lines | find "*" | str trim)
    let amd_mclk = (cat /sys/class/drm/card1/device/pp_dpm_mclk | lines | find "*" | str trim)
    
    print $"Profile: ($amd_perf)"
    print $"Core:    ($amd_sclk)"
    print $"Memory:  ($amd_mclk)"
    print ""

    if (which nvidia-smi | is-empty) == false {
        print $"($green)--- NVIDIA GPU 2080 Ti ---($reset)"
        nvidia-smi --query-gpu=utilization.gpu,utilization.memory,clocks.current.graphics,clocks.current.memory --format=csv,noheader,nounits
        | from csv --separator "," 
        | rename gpu_util mem_util core_mhz mem_mhz
        | table
    }

    print $"($yellow)--- Environment ---($reset)"
    print $"WLR_DRM_DEVICES: ($env.WLR_DRM_DEVICES? | default 'Not Set')"
}

# Set AMD GPU performance level (auto | high | low)
export def set-perf [level: string = "auto"] {
    if $level not-in ["auto", "high", "low"] {
        print $"Error: level must be auto, high, or low"
        return
    }
    
    print $"Setting AMD performance level to ($level)..."
    # Using sudo since this requires root
    echo $level | sudo tee /sys/class/drm/card1/device/power_dpm_force_performance_level
}

def main [] {
    stats
}
