{
  pkgs,
  config,
  ...
}: {
  imports = [
    # Mostly user-specific configuration
    ./variables.nix

    # Programs
    ../../modules/home/programs/shell
    ../../modules/home/programs/fetch
    ../../modules/home/programs/git

  ];

  home = {
    inherit (config.var) username;
    homeDirectory = "/home/" + config.var.username;

    packages = with pkgs; [
      # Dev
      go
      nodejs
      python3
      jq
      just
      pnpm
      wireguard-tools
      duckdb

      # Utils
      zip
      unzip
      optipng
      pfetch
      btop
      fastfetch
      tailscale
    ];

    # Don't touch this
    stateVersion = "25.11";
  };

  programs.home-manager.enable = true;
}
