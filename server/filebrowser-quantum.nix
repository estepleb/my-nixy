{ config, pkgs, ... }:
let
  host = "filebrowser.${config.var.tailnet}";
  port = 8081;
  # Uncomment when Authelia is ready:
  # oidcIssuer = "https://auth.${config.var.tailnet}";
  # oidcClientId = "opencloud";
in
{
  services.caddy.virtualHosts."${host}" = {
    extraConfig = ''
      bind tailscale/filebrowser
      reverse_proxy 127.0.0.1:${toString port}
    '';
  };

  services = {
    filebrowser = {
      enable = true;
      package = pkgs.filebrowser-quantum;
      settings = {
        port = port;
      };
  };
};
}
