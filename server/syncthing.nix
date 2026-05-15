{ config, lib, pkgs, ... }:
let
  guiPort = 8384;
  domain = "syncthing.${config.var.tailnet}";
in
{
  config = {
    services.caddy.virtualHosts."${domain}" = {
      extraConfig = ''
        bind tailscale/syncthing
        reverse_proxy 127.0.0.1:${toString guiPort}
      '';
    };
  
    services.syncthing = {
      enable = true;
      openDefaultPorts = true;
      user = config.var.username;
      dataDir = "/home/${config.var.username}";
      extraFlags = [ ];

      # Stable device ID across rebuilds - requires sops secrets
      # key = config.sops.secrets.syncthing-key.path;
      # cert = config.sops.secrets.syncthing-cert.path;

      settings = {
        gui = {
          address = "127.0.0.1:${toString guiPort}";
          insecureSkipHostcheck = true;
          extraOptions.insecureAllowedHostnames = [ domain ];
          # Uncomment to add credentials
          # user = "myuser";
          # password = "mypassword";
        };

        devices = {
          # Add devices here after pairing, or to pre-authorize them
          # "device1" = { id = "DEVICE-ID-GOES-HERE"; };
          # "device2" = { id = "DEVICE-ID-GOES-HERE"; };
        };

        folders = {
          # Basic folder synced with multiple devices
          # "Documents" = {
          #   path = "/home/${config.var.username}/Documents";
          #   devices = [ "device1" "device2" ];
          # };

          # Folder with permission syncing enabled
          # "Example" = {
          #   path = "/home/${config.var.username}/Example";
          #   devices = [ "device1" ];
          #   ignorePerms = false;
          # };

          # Folder with encrypted sync to an untrusted device
          # "Sensitive" = {
          #   path = "/home/${config.var.username}/Sensitive";
          #   devices = [
          #     "device1"  # trusted, gets decrypted contents
          #     {
          #       name = "device2";  # untrusted, gets encrypted copy
          #       encryptionPasswordFile = config.sops.secrets.syncthing-encryption-password.path;
          #     }
          #   ];
          # };
        };
      };
    };
  };
}
