{ 
  pkgs,
  inputs,
  ...
}:
{
services.displayManager.dms-greeter = {
  compositor = {
    name = "mango"; # Required. Can be also "hyprland" or "sway"
    customConfig = ''
      # Optional custom compositor configuration
    '';
  };

  # Sync your user's DankMaterialShell theme with the greeter. You'll probably want this
  configHome = "/home/estepleb";

  # Custom config files for non-standard config locations
  configFiles = [
    "/home/estepleb/.config/DankMaterialShell/settings.json"
  ];

  # Save the logs to a file
  logs = {
    save = true; 
    path = "/tmp/dms-greeter.log";
  };

  # Custom Quickshell Package    
  quickshell.package = inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.quickshell; # Quickshell from source
  package = inputs.dms.packages.${pkgs.stdenv.hostPlatform.system}.default; # Use DMS from flake while keeping module config options

};
}
