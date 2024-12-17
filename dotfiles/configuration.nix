# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

# NixOS-WSL specific options are documented on the NixOS-WSL repository:
# https://github.com/nix-community/NixOS-WSL

{ config, lib, pkgs, ... }:

{
  imports = [
    # include NixOS-WSL modules
    <nixos-wsl/modules>
  ];

  wsl.enable = true;
  wsl.defaultUser = "jmarsh";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

  time.timeZone = "America/Denver";
  
  nixpkgs = {
    config = {
      allowUnfree = true;
      packageOverrides = pkgs: {
        unstable = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz") {};
      };
    };
  };

  users.users.jmarsh = {
    isNormalUser = true;
    extraGroups = ["wheel"];
    shell = pkgs.unstable.nushell;
  };

  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = true;

  nix = {
    settings = {
      trusted-users = ["jmarsh"];
      auto-optimise-store = true;
    };
  };

  environment.variables = {
     # LIBCLANG_PATH = "${pkgs.llvmPackages_19.libclang.lib}/lib";
  };

  environment.systemPackages = with pkgs; [
    neovim
    unstable.nushell
    git
    rustup
    #llvmPackages_19.libllvm
    nodejs
    hyperfine
    bat
    delta
    ripgrep
    hex
    bandwhich
    bingrep
    prettyping
    fnm
    go
    gh
    lsb-release
    gnupg
    bitwarden-cli
    wget
    z3
  ];
}
