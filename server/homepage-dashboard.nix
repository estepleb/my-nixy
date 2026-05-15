{ config, pkgs, ... }:
let
  host = "homepage.${config.var.tailnet}";
  port = 8082;
  # Uncomment when Authelia is ready:
  # oidcIssuer = "https://auth.${config.var.tailnet}";
  # oidcClientId = "opencloud";
in
{
  # sops.secrets.homepage-dashboard-env = {
  #   sopsFile = ../hosts/nix-vm/secrets/secrets.yaml;
  #   format = "yaml";
  #   owner = config.services.homepage-dashboard.user;
  #   group = config.services.homepage-dashboard.group;
  #   mode = "0400";
  # };

  virtualisation.oci-containers.containers.socket-proxy = {
    image = "lscr.io/linuxserver/socket-proxy:latest";
    ports = [ "127.0.0.1:2375:2375" ];
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
      encode zstd gzip
      reverse_proxy 127.0.0.1:${toString port}
    '';
  };
  
  services.homepage-dashboard = {
    enable = true;
    package = pkgs.homepage-dashboard;
    allowedHosts = "localhost:${toString port},127.0.0.1:${toString port},homepage.${config.var.tailnet}";
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
      {
        Developer = [
          { Github = [{ abbr = "GH"; href = "https://github.com/"; }]; }
          { Tailscale = [{ abbr = "TS"; href = "https://login.tailscale.com/admin/machines"; }]; }
        ];
      }
      {
        Social = [
          { Reddit = [{ abbr = "RE"; href = "https://reddit.com/"; }]; }
        ];
      }
      {
        Entertainment = [
          { YouTube = [{ abbr = "YT"; href = "https://youtube.com/"; }]; }
        ];
      }
    ];
    services = [
      {
        "Utilities" = [
          {
            "Proxmox" = {
              icon = "proxmox.png";
              href = "https://proxmox.${config.var.tailnet}";
              description = "Lenovo m90q Proxmox";
            };
          }
          {
            "Adguard" = {
              icon = "adguard-home.png";
              href = "https://adguard.${config.var.tailnet}";
              description = "DNS Filter";
            };
          }
        ];
      }
    ];
    widgets = [
      {
        resources = {
          cpu = true;
          disk = "/";
          memory = true;
        };
      }
      {
        search = {
          provider = "duckduckgo";
          target = "_blank";
        };
      }
    ];
    kubernetes = {};
    # proxmox = {
    #   pve = {
    #     url = "https://proxmox.${config.var.tailnet}";
    #     token = "username@pam!Token ID";
    #     secret = "secret";
    #   };
    # };
    docker = {
      my-docker = {
        host = "127.0.0.1";
        port = 2375;
      };
    };
    customJS = "";
    customCSS = "";
  };
}
