{ config, pkgs, ... }:
{
  sops.secrets.services-tsauthkey-env = {
    sopsFile = "${config.var.secretsDirectory}/tailscale.env";
    owner = config.services.caddy.user;
    format = "dotenv";
  };

  services.caddy = {
    enable = true;
    package = pkgs.caddy.withPlugins {
      plugins = [
        "github.com/jasonlovesdoggo/caddy-defender@v0.8.5"
        "github.com/tailscale/caddy-tailscale@v0.0.0-20250207163903-69a970c84556"
      ];
      hash = "sha256-deSMEs9pmbmc6B+IexAjywpw7cCRn1ZOCTbVJve8SjI=";
    };

    globalConfig = ''
      servers {
      }
    '';

    environmentFile = config.sops.secrets.services-tsauthkey-env.path;
  };
}
