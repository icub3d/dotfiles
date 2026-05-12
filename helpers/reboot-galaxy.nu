# Reboot the Marshian Galaxy safely

def wait-for-ssh [host: string] {
    print $"⏳ Waiting for ($host) to be reachable via SSH..."
    loop {
        if (do { ssh -o ConnectTimeout=5 -o BatchMode=yes $host "exit" } | complete | get exit_code) == 0 {
            break
        }
        sleep 5sec
    }
    print $"✅ ($host) is back online."
}

def wait-for-k8s-node [node: string] {
    print $"⏳ Waiting for K8s node ($node) to be Ready..."
    loop {
        let status = (kubectl get node $node -o json | from json | get status.conditions | where type == "Ready" | first | get status)
        if $status == "True" {
            break
        }
        sleep 5sec
    }
    print $"✅ K8s node ($node) is Ready."
}

def reboot-k8s-node [node: string] {
    print $"\n(ansi blue)🔄 Safe Rebooting K8s Node: ($node)(ansi reset)"
    
    print $"📦 Draining ($node)..."
    kubectl drain $node --ignore-daemonsets --delete-emptydir-data --force
    
    print $"🚀 Rebooting ($node)..."
    ssh $node "doas reboot"
    
    # Wait a bit for it to actually start rebooting
    sleep 15sec
    
    wait-for-ssh $node
    wait-for-k8s-node $node
    
    print $"🔓 Uncordoning ($node)..."
    kubectl uncordon $node
}

def reboot-generic-node [node: string, sudo_cmd: string = "doas"] {
    print $"\n(ansi blue)🔄 Rebooting Node: ($node)(ansi reset)"
    
    print $"🚀 Rebooting ($node)..."
    ssh $node $"($sudo_cmd) reboot"
    
    # Wait a bit
    sleep 15sec
    
    wait-for-ssh $node
}

export def main [] {
    let workers = ["k8s4", "k8s3"]
    let control_planes = ["k8s2", "k8s1", "k8s0"]
    let generic_alpine = ["srv2", "wireguard"]
    let generic_debian = ["pihole"]

    print $"(ansi green)🪐 Starting Marshian Galaxy Safe Reboot Protocol...(ansi reset)"

    for node in $workers {
        reboot-k8s-node $node
    }

    for node in $control_planes {
        reboot-k8s-node $node
    }

    for node in $generic_alpine {
        reboot-generic-node $node "doas"
    }

    for node in $generic_debian {
        reboot-generic-node $node "sudo"
    }

    print $"\n(ansi green)✨ All systems in the Marshian Galaxy have been safely rebooted! (ansi reset)"
}
