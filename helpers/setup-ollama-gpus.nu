#!/usr/bin/env nu

# Set up multi-GPU Ollama service configuration.
def main [] {
    let dotfiles_root = ($env.FILE_PWD | path dirname)
    
    print "(ansi green)⚙️ Setting up multi-GPU Ollama configurations...(ansi reset)"
    
    # Define source paths
    let cuda_service_src = ($dotfiles_root | path join "helpers/ollama-cuda.service")
    let amd_override_src = ($dotfiles_root | path join "helpers/ollama-amd-override.conf")
    
    # Define target paths
    let cuda_service_dest = "/etc/systemd/system/ollama-cuda.service"
    let amd_override_dir = "/etc/systemd/system/ollama.service.d"
    let amd_override_dest = $"($amd_override_dir)/override.conf"
    
    # Write CUDA service
    print $"📦 Installing CUDA service to ($cuda_service_dest)..."
    sudo cp $cuda_service_src $cuda_service_dest
    
    # Write AMD override
    print $"📦 Installing AMD override to ($amd_override_dest)..."
    sudo mkdir -p $amd_override_dir
    sudo cp $amd_override_src $amd_override_dest
    
    # Reload and restart systemd services
    print "🔄 Reloading systemd manager configuration..."
    sudo systemctl daemon-reload
    
    print "🚀 Restarting AMD Ollama service (port 11434)..."
    sudo systemctl restart ollama.service
    
    print "🚀 Starting/Enabling CUDA Ollama service (port 11435)..."
    sudo systemctl enable --now ollama-cuda.service
    sudo systemctl restart ollama-cuda.service
    
    print $"\n(ansi green_bold)✅ Multi-GPU configuration successfully applied!(ansi reset)"
    print $"(ansi cyan)AMD \(7900 XTX\) is running on port 11434 \(default 'ollama' commands\)(ansi reset)"
    print $"(ansi cyan)NVIDIA \(2080 Ti\) is running on port 11435 \(use 'oc' commands\)(ansi reset)"
}
