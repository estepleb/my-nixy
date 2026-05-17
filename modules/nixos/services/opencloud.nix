{ config, pkgs, ... }:
let
  domain = "opencloud.${config.var.tailnet}";
  port = 9200;
  # Uncomment when Authelia is ready:
  # oidcIssuer = "https://auth.${config.var.tailnet}";
  # oidcClientId = "opencloud";
in
{
  sops.secrets.opencloud-env = {
    sopsFile = ../hosts/nix-vm/secrets/sops-files/opencloud.env;
    format = "dotenv";
    owner = config.services.opencloud.user;
    group = config.services.opencloud.group;
    mode = "0400";
  };

  services.homepage-dashboard.services = [
    {
      "Personal" = [
        {
          "Opencloud" = {
            icon = "opencloud.png";
            description = "File share cloud";
            href = "https://${domain}";
          };
        }
      ];
    }
  ];
  
  services.caddy.virtualHosts."${domain}" = {
    extraConfig = ''
      bind tailscale/opencloud
      encode zstd gzip
      reverse_proxy 127.0.0.1:${toString port}
    '';
  };

  services.opencloud = {
    enable = true;
    url = "https://${domain}";
    stateDir = "/var/lib/opencloud";
    address = "127.0.0.1";
    inherit port;
    environmentFile = config.sops.secrets.opencloud-env.path;

    environment = {
      OC_INSECURE = "true";
      OC_LOG_LEVEL = "warn";
      PROXY_TLS = "false";
      COLLABORATION_APP_NAME = "OnlyOffice"; # PascalCase name of service
      COLLABORATION_APP_PRODUCT = "Onlyoffice";# Collabora, OnlyOffice, Microsoft365 or MicrosoftOfficeOnline
      COLLABORATION_APP_ADDR = "office.${config.var.tailnet}"; # The URL of the collaborative editing app (onlyoffice, collabora, etc).
      COLLABORATION_APP_INSECURE = "false"; # In case you are using a self signed certificate for the WOPI app you can tell the collaboration service to allow an insecure connection.
      COLLABORATION_WOPI_SRC = "office.${config.var.tailnet}"; # The external address of the collaboration service. The target app (onlyoffice, collabora, etc) will use this address to read and write files from OpenCloud.
      
      # Uncomment when Authelia is ready:
      # OC_EXCLUDE_RUN_SERVICES = "idp";
      # OC_OIDC_ISSUER = oidcIssuer;
      # PROXY_OIDC_ISSUER = oidcIssuer;
      # PROXY_OIDC_REWRITE_WELLKNOWN = "false";
      # PROXY_OIDC_ACCESS_TOKEN_VERIFY_METHOD = "none";
      # PROXY_OIDC_SKIP_USER_INFO = "false";
      # WEB_OIDC_CLIENT_ID = oidcClientId;
      # PROXY_AUTOPROVISION_ACCOUNTS = "true";
      # PROXY_AUTOPROVISION_CLAIM_USERNAME = "preferred_username";
      # PROXY_AUTOPROVISION_CLAIM_EMAIL = "email";
      # PROXY_AUTOPROVISION_CLAIM_DISPLAYNAME = "name";
      # PROXY_AUTOPROVISION_CLAIM_GROUPS = "groups";
      # PROXY_USER_OIDC_CLAIM = "preferred_username";
      # PROXY_USER_CS3_CLAIM = "username";
      # GRAPH_USERNAME_MATCH = "none";
    };

    settings = {
      opencloud = {
        graph.spaces.insecure = true;
        proxy.insecure_backends = true;
      };
      web.web.config.server = "https://${domain}";
      # Uncomment when Authelia is ready:
      # csp.directives = {
      #   "connect-src" = [ "https://${host}/" oidcIssuer ];
      #   "frame-src" = [ "https://${host}/" oidcIssuer ];
      #   "script-src" = [ "'self'" "'unsafe-inline'" "'unsafe-eval'" ];
      # };
      # web.web.config.oidc = {
      #   metadata_url = "${oidcIssuer}/.well-known/openid-configuration";
      #   authority = oidcIssuer;
      #   client_id = oidcClientId;
      #   response_type = "code";
      #   scope = "openid offline_access profile email groups";
      # };
    };
  };
}
