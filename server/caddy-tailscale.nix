{ config, pkgs, ... }:
let
  proxmoxIP = "192.168.12.150:8006";
  adguardIP = "192.168.12.94:80";
in
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
    virtualHosts = {
      "proxmox.${config.var.tailnet}" = {
        extraConfig = ''
          bind tailscale/proxmox
          encode zstd gzip
          reverse_proxy https://${proxmoxIP} {
            transport http {
              tls_insecure_skip_verify
            }
          }
        '';
      };
      "adguard.${config.var.tailnet}" = {
        extraConfig = ''
          bind tailscale/adguard
          encode zstd gzip
          reverse_proxy https://${adguardIP}
        '';
      };
    };
  };
}
