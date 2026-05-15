{ self, config, lib, pkgs, ... }:
let
  officeHost = "office.${config.var.tailnet}";
  onlyofficePort = 8086;
in {
  sops.secrets = {
    onlyoffice-jwt-secret = {
      sopsFile = ../hosts/nix-vm/secrets/secrets.yaml;
      format = "yaml";
      owner = "onlyoffice";
      group = "nginx";
      mode = "0440";
      restartUnits = [ "nginx.service" "onlyoffice-docservice.service" ];
    };
    onlyoffice-nonce = {
      sopsFile = ../hosts/nix-vm/secrets/secrets.yaml;
      format = "yaml";
      owner = "onlyoffice";
      group = "nginx";
      mode = "0440";
      restartUnits = [ "nginx.service" "onlyoffice-docservice.service" ];
    };

  };

  environment.systemPackages = with pkgs; [ winePackages.fonts ];

  services.nginx = {
    defaultListenAddresses = [ "127.0.0.1" ];
    virtualHosts = {
      "${officeHost}".listen = [{ addr = "127.0.0.1"; port = onlyofficePort; }];
    };
  };

  services.caddy.virtualHosts = {
    "${officeHost}".extraConfig = ''
      bind tailscale/office
      reverse_proxy 127.0.0.1:${toString onlyofficePort}
    '';
  };

  services.onlyoffice = {
    enable = true;
    hostname = officeHost;
    port = onlyofficePort;
    jwtSecretFile = config.sops.secrets.onlyoffice-jwt-secret.path;
    securityNonceFile = config.sops.secrets.onlyoffice-nonce.path;
  };
}
