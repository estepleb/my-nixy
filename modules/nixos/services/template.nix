{ config, pkgs, ... }:
let
  domain = "opencloud.${config.var.tailnet}";
  port = 9200;
  # Uncomment when Authelia is ready:
  # oidcIssuer = "https://auth.${config.var.tailnet}";
  # oidcClientId = "opencloud";
in
{
  sops.secrets.opencloud-env = {
    sopsFile = ../hosts/nix-vm/secrets/sops-files/opencloud.env;
    format = "dotenv";
    owner = config.services.opencloud.user;
    group = config.services.opencloud.group;
    mode = "0400";
  };

  services.homepage-dashboard.services = [
    {
      "Personal" = [
        {
          "Opencloud" = {
            icon = "opencloud.png";
            description = "File share cloud";
            href = "https://${domain}";
          };
        }
      ];
    }
  ];
  
  services.caddy.virtualHosts."${domain}" = {
    extraConfig = ''
      bind tailscale/opencloud
      encode zstd gzip
      reverse_proxy 127.0.0.1:${toString port}
    '';
  };


}
