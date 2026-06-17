#!/usr/bin/env nu

# NixOS VM Manager (User Space)
# A utility to easily create, manage, and snapshot a NixOS test VM under qemu:///session.

# Default connection URI for user space
const URI = "qemu:///session"

# Print usage instructions
def main [] {
    print $"NixOS VM Manager (User Space)"
    print $"\nUsage:"
    print $"  nu helpers/nixos-vm.nu create            # Create and start the VM"
    print $"  nu helpers/nixos-vm.nu start             # Start the VM"
    print $"  nu helpers/nixos-vm.nu stop              # Gracefully stop the VM"
    print $"  nu helpers/nixos-vm.nu destroy           # Force stop the VM"
    print $"  nu helpers/nixos-vm.nu status            # Show VM status"
    print $"  nu helpers/nixos-vm.nu delete            # Delete VM and its disks"
    print $"  nu helpers/nixos-vm.nu snapshot-create   # Create a snapshot"
    print $"  nu helpers/nixos-vm.nu snapshot-list     # List snapshots"
    print $"  nu helpers/nixos-vm.nu snapshot-restore  # Restore to a snapshot"
    print $"  nu helpers/nixos-vm.nu snapshot-delete   # Delete a snapshot"
    print $"\nUse `nu helpers/nixos-vm.nu <subcommand> --help` for details."
}

# Create a new NixOS VM
def "main create" [
    --name: string = "nixos-test"          # Name of the virtual machine
    --ram: int = 8192                      # RAM in MB (default: 8192)
    --vcpus: int = 4                       # Number of CPU cores (default: 4)
    --disk-size: int = 40                  # Disk size in GB (default: 40)
    --iso: string = "~/Downloads/nixos-graphical-26.05.1947.a0374025a863-x86_64-linux.iso" # Path to NixOS ISO
] {
    let iso_path = ($iso | path expand)
    if not ($iso_path | path exists) {
        print $"(ansi red)Error: ISO file not found at ($iso_path)(ansi reset)"
        return
    }

    # Check if VM already exists
    let vm_check = (do { virsh -c $URI dominfo $name } | complete)
    if $vm_check.exit_code == 0 {
        print $"(ansi yellow)Warning: A VM named '($name)' already exists. Use 'start' or 'delete' instead.(ansi reset)"
        return
    }

    print $"(ansi green)🚀 Creating NixOS VM '($name)' in User Space... (ansi reset)"
    print $"  RAM: ($ram) MB"
    print $"  CPUs: ($vcpus)"
    print $"  Disk: ($disk_size) GB"
    print $"  ISO: ($iso_path)"

    # Ensure local libvirt images directory exists
    let disk_dir = ($nu.home-dir | path join ".local/share/libvirt/images")
    if not ($disk_dir | path exists) {
        mkdir $disk_dir
    }
    let disk_path = ($disk_dir | path join $"($name).qcow2")

    let res = (do {
        virt-install ...[
            --connect $URI
            --name $name
            --ram $ram
            --vcpus $vcpus
            --disk $"path=($disk_path),size=($disk_size),format=qcow2,bus=virtio"
            --cdrom $iso_path
            --os-variant "nixos-unstable"
            --network "passt,portForward=2222:22"
            --graphics "spice"
            --boot "uefi,boot0.dev=cdrom,boot1.dev=hd"
            --noautoconsole
        ]
    } | complete)

    if $res.exit_code != 0 {
        print $"(ansi red)Error creating VM:(ansi reset)"
        print $res.stderr
        return
    }

    print $"\n(ansi green)🎉 VM '($name)' successfully created and started!(ansi reset)"
    print $"\nTo view the VM screen, run:"
    print $"(ansi cyan)  virt-viewer ($name)(ansi reset)"
    print $"or manage it visually through `virt-manager`."
}

# Start the NixOS VM
def "main start" [
    name: string = "nixos-test" # Name of the VM to start
] {
    print $"(ansi green)Starting ($name)...(ansi reset)"
    let res = (do { virsh -c $URI start $name } | complete)
    if $res.exit_code != 0 {
        print $res.stderr
    } else {
        print $"VM ($name) started. Run `virt-viewer ($name)` to view the screen."
    }
}

# Gracefully stop the NixOS VM
def "main stop" [
    name: string = "nixos-test" # Name of the VM to stop
] {
    print $"(ansi yellow)Gracefully stopping ($name)...(ansi reset)"
    let res = (do { virsh -c $URI shutdown $name } | complete)
    if $res.exit_code != 0 {
        print $res.stderr
    }
}

# Force stop the NixOS VM
def "main destroy" [
    name: string = "nixos-test" # Name of the VM to kill
] {
    print $"(ansi red)Force stopping ($name)...(ansi reset)"
    let res = (do { virsh -c $URI destroy $name } | complete)
    if $res.exit_code != 0 {
        print $res.stderr
    }
}

# Show status of the NixOS VM
def "main status" [
    name: string = "nixos-test" # Name of the VM
] {
    let res = (do { virsh -c $URI dominfo $name } | complete)
    if $res.exit_code != 0 {
        print $"(ansi red)VM ($name) not found.(ansi reset)"
        return
    }
    print $res.stdout

    # Show snapshots
    print $"\n(ansi blue)--- Snapshots ---(ansi reset)"
    let snaps = (do { virsh -c $URI snapshot-list $name } | complete)
    if $snaps.exit_code == 0 {
        print $snaps.stdout
    } else {
        print "No snapshots or unable to list snapshots."
    }
}

# Delete the NixOS VM and its disk
def "main delete" [
    name: string = "nixos-test" # Name of the VM to delete
    --force (-f)                # Bypass confirmation prompt
] {
    if not $force {
        print $"(ansi red)WARNING: This will delete the VM '($name)' and all its snapshots/disks!(ansi reset)"
        let confirm = (input "Are you sure you want to proceed? (y/N): ")
        if ($confirm | str downcase | str trim) != "y" {
            print "Aborted."
            return
        }
    }

    # Ensure VM is stopped first
    print "Stopping VM if running..."
    do { virsh -c $URI destroy $name } | complete

    print "Deleting VM definition and disks..."
    let res = (do { virsh -c $URI undefine $name --remove-all-storage --nvram } | complete)
    if $res.exit_code != 0 {
        print $res.stderr
    } else {
        print $"(ansi green)Deleted VM ($name) and all associated storage.(ansi reset)"
    }
}

# Create a snapshot of the NixOS VM
def "main snapshot-create" [
    snap_name: string                  # Name of the snapshot (no spaces)
    --vm: string = "nixos-test"        # Name of the VM
    --description: string = ""        # Description for the snapshot
] {
    # Check if VM is running
    let dom_info = (do { virsh -c $URI dominfo $vm } | complete)
    if $dom_info.exit_code != 0 {
        print $"(ansi red)VM ($vm) not found.(ansi reset)"
        return
    }
    
    let is_running = ($dom_info.stdout | lines | any {|line| $line | str starts-with "State:" and ($line | str contains "running")})

    if $is_running {
        print $"(ansi yellow)VM is running. Temporarily stopping VM to take a safe offline snapshot... (ansi reset)"
        do { virsh -c $URI destroy $vm } | complete
    }

    print $"(ansi green)Creating snapshot '($snap_name)' for VM '($vm)'...(ansi reset)"
    let res = (do { 
        virsh -c $URI snapshot-create-as $vm $snap_name --description $description
    } | complete)
    
    if $res.exit_code != 0 {
        print $res.stderr
    } else {
        print $"(ansi green)Snapshot '($snap_name)' created successfully.(ansi reset)"
    }

    if $is_running {
        print $"(ansi yellow)Starting VM back up...(ansi reset)"
        do { virsh -c $URI start $vm } | complete
    }
}

# List snapshots for the NixOS VM
def "main snapshot-list" [
    --vm: string = "nixos-test" # Name of the VM
] {
    let res = (do { virsh -c $URI snapshot-list $vm } | complete)
    if $res.exit_code != 0 {
        print $res.stderr
    } else {
        print $res.stdout
    }
}

# Restore/Revert the NixOS VM to a snapshot
def "main snapshot-restore" [
    snap_name: string                  # Name of the snapshot to restore
    --vm: string = "nixos-test"        # Name of the VM
] {
    # Check if VM is running
    let dom_info = (do { virsh -c $URI dominfo $vm } | complete)
    let is_running = if $dom_info.exit_code == 0 {
        $dom_info.stdout | lines | any {|line| $line | str starts-with "State:" and ($line | str contains "running")}
    } else {
        false
    }

    if $is_running {
        print "Stopping VM..."
        do { virsh -c $URI destroy $vm } | complete
    }

    print $"(ansi yellow)Restoring VM '($vm)' to snapshot '($snap_name)'...(ansi reset)"
    let res = (do { virsh -c $URI snapshot-revert $vm $snap_name } | complete)
    if $res.exit_code != 0 {
        print $res.stderr
    } else {
        print $"(ansi green)VM '($vm)' successfully restored to snapshot '($snap_name)'.(ansi reset)"
    }

    if $is_running {
        print $"(ansi yellow)Starting VM back up...(ansi reset)"
        do { virsh -c $URI start $vm } | complete
    }
}

# Delete a snapshot
def "main snapshot-delete" [
    snap_name: string                  # Name of the snapshot to delete
    --vm: string = "nixos-test"        # Name of the VM
] {
    print $"(ansi red)Deleting snapshot '($snap_name)' for VM '($vm)'...(ansi reset)"
    let res = (do { virsh -c $URI snapshot-delete $vm $snap_name } | complete)
    if $res.exit_code != 0 {
        print $res.stderr
    } else {
        print $"(ansi green)Snapshot '($snap_name)' deleted.(ansi reset)"
    }
}
