# Tailscale is a VPN service that makes it easy to connect your devices between each other.
{
  config,
  inputs,
  ...
}: let
  username = config.var.username;
in {
  security.sudo.extraRules = [
    {
      users = [username];
      # Allow running Tailscale commands without a password
      commands = [
        {
          command = "/etc/profiles/per-user/${username}/bin/tailscale";
          options = ["NOPASSWD"];
        }
        {
          command = "/run/current-system/sw/bin/tailscale";
          options = ["NOPASSWD"];
        }
      ];
    }
  ];

  services.tailscale = {
    enable = true;
    package = inputs.nixpkgs-stable.legacyPackages.x86_64-linux.tailscale;
    openFirewall = true;
  };

# Tailscale Nfttable support https://wiki.nixos.org/wiki/Tailscale#Native_nftables_Support_(Modern_Setup)

  # 1. Enable the service and the firewall  networking.firewall = {
    trustedInterfaces = ["tailscale0"];
    # required to connect to Tailscale exit nodes
    checkReversePath = "loose";
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
