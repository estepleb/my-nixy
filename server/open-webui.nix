{ config, lib, pkgs, ... }:
let
  port = 11434;
  acceleration = if config.var.gpu == "nvidia" then "cuda" else "vulkan";
in
{
  environment.systemPackages = with pkgs.unstable; [
    open-webui
  ];


}
