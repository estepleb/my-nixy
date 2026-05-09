{ config, pkgs, ... }:
let
  host = "opencloud.${config.var.tailnet}";
  port = 9200;
  # Uncomment when Authelia is ready:
  # oidcIssuer = "https://auth.${config.var.tailnet}";
  # oidcClientId = "opencloud";
in
{
  sops.secrets.opencloud-env = {
    sopsFile = "${config.var.secretsDirectory}/opencloud.env";
    format = "dotenv";
    owner = config.services.opencloud.user;
    group = config.services.opencloud.user;
    mode = "0400";
  };

  services.caddy.virtualHosts."${host}" = {
    extraConfig = ''
      bind tailscale/opencloud
      reverse_proxy 127.0.0.1:${toString port}
    '';
  };

  services.opencloud = {
    enable = true;
    url = "https://${host}";
    address = "127.0.0.1";
    inherit port;
    environmentFile = config.sops.secrets.opencloud-env.path;

    environment = {
      OC_INSECURE = "true";
      OC_LOG_LEVEL = "warn";
      PROXY_TLS = "false";
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
      web.web.config.server = "https://${host}";
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
