{config, pkgs, ...}: {
  imports = [
    # NixOS module
    ../../nixos/home-manager.nix
    ../../nixos/nix.nix
    ../../nixos/grub-vm.nix
    ../../nixos/users.nix
    ../../nixos/utils.nix
    ../../nixos/docker.nix
    ../../nixos/tailscale.nix
    ../../nixos/virtual-machine.nix

    # NixOS server modules
    ../../server/ssh.nix
    # ../../server-modules/bitwarden.nix
    ../../server/firewall.nix
    ../../server/caddy-tailscale.nix
    ../../server/opencloud.nix

    # You should leave those lines as is
    ./hardware-configuration.nix
    ./variables.nix

    ./secrets
  ];

  home-manager.users."${config.var.username}" = import ./home.nix;

  environment.systemPackages = with pkgs; [
    wget
    curl
    git
    chezmoi
    fish
    zoxide
    eza 
    bat
    fzf
    micro
    btrfs-progs
    fastfetch
    nix-search-cli
    openssl
  ];
  # Don't touch this
  system.stateVersion = "25.11";
}
