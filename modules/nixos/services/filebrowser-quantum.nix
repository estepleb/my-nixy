{ config, lib, ... }:
let
  port = 8900;
  domain = "files.${config.var.tailnet}";
in
{
  sops.secrets.filebrowser-env = {
    sopsFile = ../hosts/nix-vm/secrets/secrets.yaml;
    format = "yaml";
    mode = "0400";
  }; 
  
  environment.etc."filebrowser/config.yaml".text = ''
    server:
      port: 8900
      cacheDir: "/tmp/filebrowser"
      database: "/home/filebrowser/data/database.db"
      sources:
        - path: "/srv"
          name: Home
    auth:
      adminUsername: admin
      tokenExpirationHours: 24
      methods:
        password:
          enabled: true
          minLength: 8
          signup: true
  '';

  virtualisation.oci-containers.containers.filebrowser = {
    image = "ghcr.io/gtsteffaniak/filebrowser:latest";
    autoStart = true;
    user = "1000:1000";
    ports = [ "127.0.0.1:${toString port}:8900" ];
    volumes = [
      "/var/cache/filebrowser:/tmp/filebrowser"
      "/var/lib/filebrowser:/home/filebrowser/data"
      "/etc/filebrowser/config.yaml:/home/filebrowser/config/config.yaml:ro"
      "/srv:/srv"
    ];
    environmentFiles = [ config.sops.secrets.filebrowser-env.path ];
    environment = {
      FILEBROWSER_CONFIG = "/home/filebrowser/config/config.yaml";
    };
    extraOptions = [ "--cap-add=NET_BIND_SERVICE" ];
  };

  systemd.tmpfiles.rules = [
    "d /var/cache/filebrowser 0750 1000 1000 -"
    "d /var/lib/filebrowser   0750 1000 1000 -"
    "d /srv                   0755 root  root  -"
  ];

  services.caddy.virtualHosts."${domain}" = {
    extraConfig = ''
      bind tailscale/files
      encode zstd gzip
      reverse_proxy 127.0.0.1:${toString port}
    '';
  };
}
