{ config, pkgs, ... }:

{
  sops.secrets.tailscale-env = {
    sopsFile = ./secrets/sops-files/tailscale.env;
    format = "dotenv";
    owner = config.services.tailscale.user;
    group = config.services.tailscale.user;
    mode = "0400";
  };
  # 1. Enable the service and the firewall
  services.tailscale = {
    enable = true;
    # If you would like to use a preauthorized key
    authKeyFile = "/run/secrets/tailscale_key";
  };
  networking.nftables.enable = true;
  networking.firewall = {
    enable = true;
    # Always allow traffic from your Tailscale network
    trustedInterfaces = [ "tailscale0" ];
    # Allow the Tailscale UDP port through the firewall
    allowedUDPPorts = [ config.services.tailscale.port ];
  };

  # 2. Force tailscaled to use nftables (Critical for clean nftables-only systems)
  # This avoids the "iptables-compat" translation layer issues.
  systemd.services.tailscaled.serviceConfig.Environment = [ 
    "TS_DEBUG_FIREWALL_MODE=nftables" 
  ];

  # 3. Optimization: Prevent systemd from waiting for network online 
  # (Optional but recommended for faster boot with VPNs)
  systemd.network.wait-online.enable = false; 
  boot.initrd.systemd.network.wait-online.enable = false;
}
