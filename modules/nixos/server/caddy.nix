# https://wiki.nixos.org/wiki/Tailscale#Configuring_TLS
{ config, pkgs, ... }:
{

services.caddy = {
  enable = true;
  virtualHosts."<MACHINE_NAME>.<TAILNET_NAME>".extraConfig = ''
    reverse_proxy 127.0.0.1:<port>
  '';
};
# Allow the Caddy user(and service) to edit certs
services.tailscale.permitCertUid = "caddy";
}
