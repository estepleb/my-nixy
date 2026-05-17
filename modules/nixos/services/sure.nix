# ===========================================================================
# Sure NixOS OCI Container Configuration
# ===========================================================================
#
# Purpose:
# --------
#
# This file is a NixOS OCI container configuration for self-hosting
# Sure on your local machine or on a cloud VPS.
#
# The configuration below is a "standard" setup that works out of the box,
# but if you're running this outside of a local network, it is recommended
# to set the environment variables for extra security.
#
# Setup:
# ------
#
# To run this, you should read the setup guide:
#
# https://github.com/we-promise/sure/blob/main/docs/hosting/docker.md
#
# Troubleshooting:
# ----------------
#
# If you run into problems, you should open a Discussion here:
#
# https://github.com/we-promise/sure/discussions/categories/general
#
{ config, pkgs, ... }:
let
  domain = "sure.${config.var.tailnet}";
  port = 3000;

  # Internal Docker bridge network (mirrors 'sure_net' in Compose)
  network = "sure_net";

  # Non-sensitive defaults (mirrors x-db-env anchor defaults)
  # Sensitive values (POSTGRES_PASSWORD, SECRET_KEY_BASE, OPENAI_ACCESS_TOKEN)
  # live in sops secret below.
  dbUser = "sure_user";
  dbName = "sure_production";

  # Shared environment (mirrors x-rails-env anchor) — inlined per-container
  # below because NixOS OCI containers don't support YAML anchors.
  railsEnv = {
    POSTGRES_USER = dbUser;
    POSTGRES_DB   = dbName;
    SELF_HOSTED   = "true";
    RAILS_FORCE_SSL = "false";
    RAILS_ASSUME_SSL = "true";
    DB_HOST   = "sure-db";
    DB_PORT   = "5432";
    REDIS_URL = "redis://sure-redis:6379/1";
    # NOTE: enabling OpenAI will incur costs when you use AI-related features
    # in the app (chat, rules). Make sure you have set appropriate spend limits
    # on your account before adding this.
    # OPENAI_ACCESS_TOKEN is loaded from the sops secret file below.
  };
in
{
  # ---------------------------------------------------------------------------
  # Docker network
  # Mirrors: networks: sure_net: driver: bridge
  # NixOS OCI containers don't create named networks automatically, so we
  # bootstrap it with a oneshot systemd service.
  # ---------------------------------------------------------------------------
  systemd.services.init-sure-network = {
    description = "Create sure_net Docker network";
    after    = [ "docker.service" ];
    requires = [ "docker.service" ];
    before   = [
      "docker-sure-web.service"
      "docker-sure-worker.service"
      "docker-sure-db.service"
      "docker-sure-redis.service"
    ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ${pkgs.docker}/bin/docker network inspect ${network} > /dev/null 2>&1 || \
        ${pkgs.docker}/bin/docker network create ${network}
    '';
  };

  # ---------------------------------------------------------------------------
  # Secrets
  # Mirrors: x-db-env / x-rails-env sensitive values as a dotenv sops secret.
  # Expected keys in sure.env:
  #   POSTGRES_PASSWORD
  #   SECRET_KEY_BASE
  #   OPENAI_ACCESS_TOKEN  (optional — only needed if using AI features)
  # ---------------------------------------------------------------------------
  sops.secrets.sure-env = {
    sopsFile = ../hosts/nix-vm/secrets/sops-files/sure.env;
    format = "dotenv";
    mode = "0400";
  };

  # ---------------------------------------------------------------------------
  # Homepage dashboard
  # ---------------------------------------------------------------------------
  services.homepage-dashboard.services = [
    {
      "Personal" = [
        {
          "Sure" = {
            icon = "sure.png";
            description = "Support ticket tracker";
            href = "https://${domain}";
          };
        }
      ];
    }
  ];

  # ---------------------------------------------------------------------------
  # Caddy reverse proxy
  # Mirrors: the commented-out ports block on the web service.
  # Tailscale access replaces the Docker Tailscale sidecar pattern — Caddy's
  # `bind tailscale/sure` handles exposure on the tailnet instead.
  # ---------------------------------------------------------------------------
  services.caddy.virtualHosts."${domain}" = {
    extraConfig = ''
      bind tailscale/sure
      encode zstd gzip
      reverse_proxy 127.0.0.1:${toString port}
    '';
  };

  # ---------------------------------------------------------------------------
  # OCI containers
  # restart: unless-stopped → handled by systemd's default restart-on-failure
  # service_healthy depends_on → approximated with dependsOn (start ordering
  # only; NixOS OCI does not evaluate healthchecks before unblocking dependents)
  # ---------------------------------------------------------------------------
  virtualisation.oci-containers.containers = {

    # =========================================================================
    # web
    # Mirrors: services.web (image, volumes, environment, depends_on)
    # network_mode: service:tailscale is replaced by Caddy's tailscale binding;
    # the port is published only to 127.0.0.1 so only Caddy can reach it.
    # =========================================================================
    "sure-web" = {
      image = "ghcr.io/we-promise/sure:stable";
      volumes = [
        "sure-app-storage:/rails/storage"
      ];
      # Mirrors: ports: - ${PORT:-3000}:3000 (was commented out in Compose)
      ports = [ "127.0.0.1:${toString port}:3000" ];
      environmentFiles = [ config.sops.secrets.sure-env.path ];
      environment = railsEnv;
      dependsOn = [ "sure-db" "sure-redis" ];
      extraOptions = [ "--network=${network}" ];
    };

    # =========================================================================
    # worker
    # Mirrors: services.worker (Sidekiq background job processor)
    # =========================================================================
    "sure-worker" = {
      image = "ghcr.io/we-promise/sure:stable";
      cmd = [ "bundle" "exec" "sidekiq" ];
      volumes = [
        "sure-app-storage:/rails/storage"
      ];
      environmentFiles = [ config.sops.secrets.sure-env.path ];
      environment = railsEnv;
      dependsOn = [ "sure-db" "sure-redis" ];
      extraOptions = [
        "--network=${network}"
        # dns: mirrors the explicit dns entries on the worker service
        "--dns=8.8.8.8"
        "--dns=1.1.1.1"
      ];
    };

    # =========================================================================
    # db
    # Mirrors: services.db (postgres:16)
    # healthcheck: pg_isready → passed via --health-* Docker flags
    # =========================================================================
    "sure-db" = {
      image = "postgres:16";
      volumes = [
        "sure-postgres-data:/var/lib/postgresql/data"
      ];
      environmentFiles = [ config.sops.secrets.sure-env.path ];
      environment = {
        POSTGRES_USER = dbUser;
        POSTGRES_DB   = dbName;
        # POSTGRES_PASSWORD → sops (sure-env)
      };
      extraOptions = [
        "--network=${network}"
        # healthcheck: test: [ "CMD-SHELL", "pg_isready -U $$POSTGRES_USER -d $$POSTGRES_DB" ]
        # interval: 5s  timeout: 5s  retries: 5
        "--health-cmd=pg_isready -U ${dbUser} -d ${dbName}"
        "--health-interval=5s"
        "--health-timeout=5s"
        "--health-retries=5"
      ];
    };

    # =========================================================================
    # backup
    # Mirrors: services.backup (profiles: [backup] → disabled by default)
    # Uncomment this container to enable scheduled Postgres backups.
    # =========================================================================
    # "sure-backup" = {
    #   image = "prodrigestivill/postgres-backup-local";
    #   volumes = [
    #     "/opt/sure-data/backups:/backups" # Change to your desired backup location
    #   ];
    #   environmentFiles = [ config.sops.secrets.sure-env.path ];
    #   environment = {
    #     POSTGRES_HOST = "sure-db";
    #     POSTGRES_DB   = dbName;
    #     POSTGRES_USER = dbUser;
    #     # POSTGRES_PASSWORD → sops (sure-env)
    #     SCHEDULE           = "@daily"; # Runs once a day at midnight
    #     BACKUP_KEEP_DAYS   = "7";      # Keeps the last 7 days of backups
    #     BACKUP_KEEP_WEEKS  = "4";      # Keeps 4 weekly backups
    #     BACKUP_KEEP_MONTHS = "6";      # Keeps 6 monthly backups
    #   };
    #   dependsOn = [ "sure-db" ];
    #   extraOptions = [ "--network=${network}" ];
    # };

    # =========================================================================
    # redis
    # Mirrors: services.redis (redis:latest)
    # healthcheck: redis-cli ping → passed via --health-* Docker flags
    # =========================================================================
    "sure-redis" = {
      image = "redis:latest";
      volumes = [
        "sure-redis-data:/data"
      ];
      extraOptions = [
        "--network=${network}"
        # healthcheck: test: [ "CMD", "redis-cli", "ping" ]
        # interval: 5s  timeout: 5s  retries: 5
        "--health-cmd=redis-cli ping"
        "--health-interval=5s"
        "--health-timeout=5s"
        "--health-retries=5"
      ];
    };
  };
}
