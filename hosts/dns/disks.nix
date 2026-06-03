# Samsung 990 EVO 2TB uuid=ac83855a-f3b3-4066-bcf0-288349097e67
{ config, lib, pkgs, modulesPath, ... }:

{
  fileSystems."/var/lib/docker" = 
    {
    device = "/dev/disk/by-uuid/ac83855a-f3b3-4066-bcf0-288349097e67";
    fsType = "btrfs";
    options = [ "subvol=@docker" "compress=zstd" "noatime" "nofail" ];
    };

  fileSystems."/mnt/data" = 
    {
    device = "/dev/disk/by-uuid/ac83855a-f3b3-4066-bcf0-288349097e67";
    fsType = "btrfs";
    options = [ "subvol=@data" "compress=zstd" "noatime" "nofail" ];
    };

  fileSystems."/mnt/misc" = 
    {
    device = "/dev/disk/by-uuid/ac83855a-f3b3-4066-bcf0-288349097e67";
    fsType = "btrfs";
    options = [ "subvol=@misc" "compress=zstd" "noatime" "nofail" ];
    };

  fileSystems."/mnt/backup" = 
    {
    device = "/dev/disk/by-uuid/ac83855a-f3b3-4066-bcf0-288349097e67";
    fsType = "btrfs";
    options = [ "subvol=@backup" "compress=zstd" "noatime" "nofail" ];
    };

  fileSystems."/mnt/media" = 
    {
    device = "/dev/disk/by-uuid/ac83855a-f3b3-4066-bcf0-288349097e67";
    fsType = "btrfs";
    options = [ "subvol=@media" "compress=zstd" "noatime" "nofail" ];
    };
}
