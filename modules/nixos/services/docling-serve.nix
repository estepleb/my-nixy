{ config, pkgs, ... }:
let
  service       = "docling";
  prettyName    = "Docling";
  hostname      = ""; # Overrides service as hostname
  description   = "OCR Document Server";
  category      = "Utilities";
  icon          = "docling.png";
  port          = 5001;

  # Logic
  resolvedHost  = if hostname != "" then hostname else service;
  domain        = config.var.tailnet;
  fqdn          = "${resolvedHost}.${domain}";
in
{
  sops.secrets.docling-env = {
    sopsFile = ../../../hosts/nix-vm/secrets/secrets.yaml;
    format = "yaml";
    # owner = config.services.docling-serve.user;
    mode = "0400";
  };

                                                       
  services.homepage-dashboard.services = [
    {
      "${category}" = [
        {
          "${prettyName}" = {
            icon = icon;
            description = description;
            href = "https://${fqdn}";
          };
        }
      ];
    }
  ];

  services.caddy.virtualHosts."${fqdn}" = {
    extraConfig = ''
      bind tailscale/${resolvedHost}
      encode zstd gzip
      reverse_proxy 127.0.0.1:${toString port}
    '';
  };

  services.docling-serve = {
    enable = true;
    host = "127.0.0.1";
    port = port;
    environmentFile = config.sops.secrets.docling-env.path; 
    environment = {                                          
      DOCLING_SERVE_ENABLE_UI = "True";
    };                                                       
  }; 
}
