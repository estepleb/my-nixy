# OCI Container Runtime
{ config, ... }: {
  virtualisation.oci-containers = {
    backend = "podman";
  };

  virtualisation.containers.containersConf.settings = {
    network.firewall_driver = "nftables";
  };
}
