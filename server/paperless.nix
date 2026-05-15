{ config, lib, pkgs, ... }:
let
  hostname = "paperless";
  paperlessPort = 8000;
  domain = "paperless.${config.var.tailnet}";
  # Uncomment when Authelia is ready:
  # oidcIssuer = "https://auth.${config.var.tailnet}";
  # oidcClientId = "opencloud";
in
{
  config = {
    users.users.paperless = {
      isSystemUser = true;
      group = "paperless";
      description = "Paperless-ngx service account";
      shell = pkgs.shadow;
      createHome = true;
      home = "/var/lib/paperless";
    };
    users.groups.paperless = {};
    users.users.${config.var.username}.extraGroups = [ "paperless" ];

    services.paperless = {
      enable = true;
      address = "127.0.0.1";
      port = paperlessPort;
      user = "paperless";
      dataDir = "/var/lib/paperless";
      mediaDir = "/var/lib/paperless/media";
      consumptionDir = "/var/lib/paperless/consume";
      consumptionDirIsPublic = true;
      passwordFile = config.sops.secrets.paperless-admin-password.path;

      settings = {
        PAPERLESS_URL = "https://${domain}";
        PAPERLESS_TIME_ZONE = config.var.timeZone;
        PAPERLESS_UMASK = "0027";

        # OCR
        PAPERLESS_OCR_LANGUAGE = "eng";
        PAPERLESS_OCR_USER_ARGS = ''{"continue_on_soft_render_error": true}'';

        # Consumer
        PAPERLESS_CONSUMER_RECURSIVE = true;
        PAPERLESS_CONSUMER_SUBDIRS_AS_TAGS = true;
        PAPERLESS_CONSUMER_DELETE_DUPLICATES = true;

        # Filename format
        PAPERLESS_FILENAME_FORMAT = "{{ created_year }}/{{ correspondent }}/{{ document_type }}/{{ title }}";
        PAPERLESS_FILENAME_FORMAT_REMOVE_NONE = false;

        # Tika/Gotenberg for Office document support
        PAPERLESS_TIKA_ENABLED = true;
        PAPERLESS_TIKA_ENDPOINT = "http://localhost:9998";
        PAPERLESS_TIKA_GOTENBERG_ENDPOINT = "http://localhost:3000";
      };
    };

    # Wait for data dir before starting services
    systemd.services.paperless-scheduler.after = [ "var-lib-paperless.mount" ];
    systemd.services.paperless-consumer.after = [ "var-lib-paperless.mount" ];
    systemd.services.paperless-web.after = [ "var-lib-paperless.mount" ];

    # Tika for Office document parsing
    virtualisation.oci-containers.containers.tika = {
      image = "docker.io/apache/tika:latest";
      ports = [ "127.0.0.1:9998:9998" ];
    };

    # Gotenberg for PDF rendering
    virtualisation.oci-containers.containers.gotenberg = {
      image = "docker.io/gotenberg/gotenberg:8.25";
      ports = [ "127.0.0.1:3000:3000" ];
      cmd = [
        "gotenberg"
        "--chromium-disable-javascript=true"
        "--chromium-allow-list=file:///tmp/.*"
      ];
    };

    services.caddy.virtualHosts."${domain}" = {
      extraConfig = ''
        bind tailscale/${hostname}
        reverse_proxy 127.0.0.1:${toString paperlessPort}
      '';
    };

    sops.secrets.paperless-admin-password = {
      sopsFile = ../hosts/nix-vm/secrets/secrets.yaml;
      owner = "paperless";
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/paperless              0750 paperless paperless -"
      "d /var/lib/paperless/consume      0750 paperless paperless -"
      "d /var/lib/paperless/export       0750 paperless paperless -"
      "d /var/lib/paperless/media        0750 paperless paperless -"
      "d /var/lib/paperless/media/documents 0750 paperless paperless -"
      "Z /var/lib/paperless              -    paperless paperless -"
    ];
  };
}
