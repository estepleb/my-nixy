{ config, pkgs, ... }:
{
  sops.secrets.tsauthkey = {
    sopsFile = ../hosts/nix-vm/secrets/secrets.yaml;
    format = "yaml";
    owner = config.services.caddy.user;
    group = config.services.caddy.group;
    mode = "0400";
  };

  services.caddy = {
    enable = true;
    package = pkgs.caddy.withPlugins {
      plugins = [
        "github.com/jasonlovesdoggo/caddy-defender@v0.8.5"
        "github.com/tailscale/caddy-tailscale@v0.0.0-20260106222316-bb080c4414ac"
      ];
      hash = "sha256-uyT7tiRrBcU7ydvdGzdiHsQjPV24baus4/XUT/IoqS8=";
    };

    globalConfig = ''
      servers {
      }
    '';

    environmentFile = config.sops.secrets.tsauthkey.path;
  };
}
