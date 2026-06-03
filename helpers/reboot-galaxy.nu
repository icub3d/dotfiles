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
        let status = (try {
            kubectl get node $node -o json | from json | get status.conditions | where type == "Ready" | first | get status
        } catch {
            "False"
        })
        if $status == "True" {
            break
        }
        sleep 5sec
    }
    print $"✅ K8s node ($node) is Ready."
}

def verify-vips [] {
    print $"🧪 (ansi cyan)Verifying Service VIP accessibility...(ansi reset)"
    
    # We check git.marsh.gg as the primary health indicator for the public gateway
    let check = (do { curl -I -s --max-time 5 https://git.marsh.gg } | complete)
    
    if $check.exit_code != 0 {
        print $"⚠️ (ansi yellow)VIP unreachable - exit code: ($check.exit_code). Triggering Cilium re-announcement...(ansi reset)"
        kubectl rollout restart ds -n kube-system cilium
        
        print "⏳ Waiting for Cilium rollout to settle..."
        kubectl rollout status ds -n kube-system cilium
        
        # Give it a few seconds to actually announce and the router to update ARP
        sleep 10sec
        
        let final_check = (do { curl -I -s --max-time 5 https://git.marsh.gg } | complete)
        if $final_check.exit_code == 0 {
            print $"✨ (ansi green)Networking restored! (ansi reset)"
        } else {
            print $"❌ (ansi red)Networking still problematic. Manual intervention may be required.(ansi reset)"
        }
    } else {
        print $"✅ (ansi green)Service VIPs are reachable.(ansi reset)"
    }
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

    # Verify networking after each K8s node is back to ensure we don't proceed with a broken data plane
    verify-vips
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
