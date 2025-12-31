# Users configuration for NixOS
{
  config,
  pkgs,
  ...
}: let
  username = config.var.username;
in {
  programs.zsh.enable = true;
  users = {
    defaultUserShell = pkgs.bash;

    users.${username} = {
      isNormalUser = true;
      description = "${username} account";
      extraGroups = ["networkmanager" "wheel"];
    };
  };
}
