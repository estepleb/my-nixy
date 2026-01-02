{
  pkgs,
  config,
  inputs,
  ...
}: {
  imports = [
    # Mostly user-specific configuration
    ./variables.nix

    # Programs
    ../../home/programs/kitty
    ../../home/programs/nvf
    ../../home/programs/shell
    ../../home/programs/fetch
    ../../home/programs/foot
    ../../home/programs/git
    ../../home/programs/git/signing.nix
    ../../home/programs/spicetify
    ../../home/programs/thunar
    ../../home/programs/lazygit
    ../../home/programs/discord
    ../../home/programs/tailscale

    # Scripts
    ../../home/scripts # All scripts

    # System (Desktop environment like stuff)
    ../../home/system/hyprland
    ../../home/system/mangowc
    ../../home/system/zathura
    ../../home/system/mime
    ../../home/system/udiskie

   # ./secrets # CHANGEME: You should probably remove this line, this is where I store my secrets
  ];

  home = {
    inherit (config.var) username;
    homeDirectory = "/home/" + config.var.username;

    packages = with pkgs; [
      # Apps
      bitwarden-desktop # Password manager
      vlc # Video player
      blanket # White-noise app
      obsidian # Note taking app
      planify # Todolists
      textpieces # Manipulate texts
      curtail # Compress images
      resources # Resource monitor
      mission-center # Resources monitor
      gnome-clocks # Clocks app
      gnome-text-editor # Basic graphic text editor
      gnome-calculator # Basic calculator
      mpv # Video player
      brave # Web browser

      # Privacy
      signal-desktop # Signal app, private messages
      ticktick # Privacy friendly todo app

      # Dev
      go
      bun
      docker
      nodejs
      python3
      jq
      just
      pnpm
      air
      duckdb
      inputs.eleakxir.packages.${stdenv.hostPlatform.system}.leak-utils
      caido
      wireshark
      nuclei

      # Utils
      zip
      unzip
      optipng
      jpegoptim
      pfetch
      btop
      fastfetch

      # Just cool
      peaclock
      cbonsai
      pipes
      cmatrix

      # Backup
      vscode
    ];

    # Import my profile picture, used by the hyprpanel dashboard
    file.".face.icon" = {source = ./profile_picture.png;};

    # Don't touch this
    stateVersion = "24.05";
  };

  programs.home-manager.enable = true;
}
