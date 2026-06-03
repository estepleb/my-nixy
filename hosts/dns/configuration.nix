{config, pkgs, ...}: {
  imports = [

    # Boot
  	../../modules/nixos/boot/grub-vm.nix
  	# ../../modules/nixos/boot/limine.nix
  	# ../../modules/nixos/boot/systemd-boot.nix
    # NixOS module
	../../modules/nixos/system/home-manager.nix
	../../modules/nixos/system/nix.nix
	../../modules/nixos/system/users.nix
	../../modules/nixos/system/utils.nix
	# ../../modules/nixos/system/docker.nix
	../../modules/nixos/system/tailscale.nix
	# ../../modules/nixos/system/virtual-machine.nix
	../../modules/nixos/system/oci-containers.nix

    # NixOS server modules
    ../../modules/nixos/system/ssh.nix
    # ../../modules/nixos/system/bitwarden.nix
    ../../modules/nixos/system/firewall.nix
    ../../modules/nixos/services/caddy-tailscale.nix
    # ../../modules/nixos/services/opencloud.nix
    # ../../modules/nixos/services/nextcloud.nix
    # ../../modules/nixos/services/onlyoffice.nix
    # ../../modules/nixos/services/syncthing.nix
    # ../../modules/nixos/services/ollama.nix
    # ../../modules/nixos/services/homepage-dashboard.nix
    # ../../modules/nixos/services/paperless.nix
    # ../../modules/nixos/services/filebrowser-quantum.nix

    # You should leave those lines as is
    ./hardware-configuration.nix
    ./disks.nix
    ./variables.nix

    ./secrets
  ];

  home-manager.users."${config.var.username}" = import ./home.nix;

  environment.sessionVariables = {
    NH_OS_FLAKE = config.var.configDirectory;
  };
  
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
    nh
    psmisc
  ];
  # Don't touch this
  system.stateVersion = "25.11";
}
