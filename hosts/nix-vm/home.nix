{
  pkgs,
  config,
  ...
}: {
  imports = [
    # Mostly user-specific configuration
    ./variables.nix

    # Programs
    ../../home/programs/shell
    ../../home/programs/fetch
    ../../home/programs/git

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
