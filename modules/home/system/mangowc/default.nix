{ inputs, ... }:
{
  imports = [
    inputs.mango.hmModules.mango
  ];

  wayland.windowManager.mango = {
    enable = true;
    settings = ''
      # Add your MangoWC config here
      # Example:
      # border_width = 2
      # gaps_in = 5
      # gaps_out = 10
    '';
    autostart_sh = ''
      # Add autostart commands here
      # Example:
      # waybar &
      # dunst &
    '';
  };
}
