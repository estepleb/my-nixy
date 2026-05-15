{ config, pkgs, ... }:
let
  host = "opencloud.${config.var.tailnet}";
  port = 9200;
  # Uncomment when Authelia is ready:
  # oidcIssuer = "https://auth.${config.var.tailnet}";
  # oidcClientId = "opencloud";
in
{
  # sops.secrets.homepage-dashboard-env = {
  #   sopsFile = ../hosts/nix-vm/secrets/secrets.yaml;
  #   format = "yaml";
  #   owner = config.services.opencloud.user;
  #   group = config.services.opencloud.group;
  #   mode = "0400";
  # };
  
  virtualisation.oci-containers.containers.socket-proxy = {
    image = "lscr.io/linuxserver/socket-proxy:latest";
    environmentFiles = [ /path/to/socket.env ];
    environment = {
      ALLOW_START = "0";
      ALLOW_STOP = "0";
      ALLOW_RESTARTS = "0";
      AUTH = "0";
      BUILD = "0";
      COMMIT = "0";
      CONFIGS = "0";
      CONTAINERS = "1"; # Allow access to viewing containers
      DISABLE_IPV6 = "0";
      DISTRIBUTION = "0";
      EVENTS = "1";
      EXEC = "0";
      IMAGES = "0";
      INFO = "1";
      LOG_LEVEL = "info";
      NETWORKS = "0";
      NODES = "0";
      PING = "1";
      PLUGINS = "0";
      POST = "0"; # Disallow any POST operations (effectively read-only)
      SECRETS = "0";
      SERVICES = "1"; # Allow access to viewing services (necessary when using Docker Swarm)
      SESSION = "0";
      SWARM = "0";
      SYSTEM = "0";
      TASKS = "1"; # Allow access to viewing tasks (necessary when using Docker Swarm)
      TZ = config.var.timeZone;
      VERSION = "1";
      VOLUMES = "0";
    };
    volumes = [
      "/var/run/docker.sock:/var/run/docker.sock:ro"
    ];
    extraOptions = [
      "--read-only"
      "--tmpfs=/run"
      "--health-cmd=nc -z localhost 2375 || exit 1"
      "--health-interval=10s"
      "--health-timeout=3s"
      "--health-retries=3"
      "--health-start-period=5s"
    ];
  }; 
  
  services.caddy.virtualHosts."${host}" = {
    extraConfig = ''
      bind tailscale/homepage
      reverse_proxy 127.0.0.1:${toString port}
    '';
  };

  services.homepage-dashboard = {
    enable = true;
    package = pkgs.homepage-dashboard;
    settings = {
      providers = {
        openweathermap = "openweathermapapikey";
        weatherapi = "weatherapiapikey";
        paperlessngx = {
          key = "4cb374414d6eb3177c69913d49b8d62741ca6732";
        };
        arcane = {
          key = "{{HOMEPAGE_VAR_ARCANE_KEY}}";
        };
        kopia = {
          username = "estepleb";
          password = "ZitRogue2";
        };
      };
    };

    bookmarks = [
      { Developer = [
        { Github = [{ abbr = "GH"; href = "https://github.com/"; }]; }
        { Tailscale = [{ abbr = "TS"; href = "https://login.tailscale.com/admin/machines"; }]; }
      ]; }
      { Social = [
        { Reddit = [{ abbr = "RE"; href = "https://reddit.com/"; }]; }
      ]; }
      { Entertainment = [
        { YouTube = [{ abbr = "YT"; href = "https://youtube.com/"; }]; }
      ]; }
    ];

    services = [
      { Utilities = [
        { Cockpit = {
          icon = "cockpit.png";
          href = "http://inspiron.bullhead-komodo.ts.net";
          description = "Inspiron Cockpit";
        }; }
      ]; }
    ];

    widgets = [];

    kubernetes = {};

    proxmox = {
      pve = {
        url = "https://proxmox.host.or.ip:8006";
        token = "username@pam!Token ID";
        secret = "secret";
      };
    };

    docker = {
      my-docker = {
        host = "socket-proxy";
        port = 2375;
      };
    };

    customJS = "";
    customCSS = "";
  };
}
