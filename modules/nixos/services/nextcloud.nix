{ self, config, lib, pkgs, ... }:
let
  cloudHost = "nextcloud.${config.var.tailnet}";
  officeHost = "office.${config.var.tailnet}";
  nextcloudPort = 8080;
  onlyofficePort = 8085;
in {

  sops.secrets.nextcloud-adminpass = {
    sopsFile = ../hosts/nix-vm/secrets/secrets.yaml;
    format = "yaml";
    owner = "nextcloud";
    group = "nextcloud";
    mode = "0440";
  };

  services.nginx = {
    defaultListenAddresses = [ "127.0.0.1" ];
    virtualHosts = {
      "${cloudHost}".listen  = [{ addr = "127.0.0.1"; port = nextcloudPort; }];
    };
  };

  services.caddy.virtualHosts = {
    "${cloudHost}".extraConfig = ''
      bind tailscale/nextcloud
      reverse_proxy 127.0.0.1:${toString nextcloudPort}
    '';
  };

  services.phpfpm.pools.nextcloud.settings = {
    "listen.owner" = "nginx";
    "listen.group" = "nginx";
  };

  services.nextcloud = {
    enable = true;
    hostName = cloudHost;
    package = pkgs.nextcloud32;
    database.createLocally = true;
    configureRedis = true;
    maxUploadSize = "16G";
    https = true;
    autoUpdateApps.enable = true;
    extraAppsEnable = true;
    extraApps = with config.services.nextcloud.package.packages.apps; {
      inherit calendar contacts mail notes tasks onlyoffice cookbook;
    };
    settings = {
      overwriteProtocol = "https";
      default_phone_region = "US";
    };
    config = {
      dbtype = "pgsql";
      adminuser = "admin";
      adminpassFile = config.sops.secrets.nextcloud-adminpass.path;
    };
    phpOptions."opcache.interned_strings_buffer" = "16";
  };

  services.postgresqlBackup = {
    enable = true;
    databases = [ "nextcloud" ];
    startAt = "*-*-* 04:00:00";
  };
}
