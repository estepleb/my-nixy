{
  pkgs,
  inputs,
  ...
}: {
services.displayManager.dms-greeter = {
  compositor = {
    enable = true;
    name = "mangowc"; # Required. Can be also "hyprland" or "sway"
    customConfig = ''
      # Optional custom compositor configuration
      # MangoWC greeter configuration


      # source=./mangowc/monitors.conf
      # Primary laptop display (internal)
      monitorrule=eDP-1,0.55,1,tile,0,1.67,0,0,2560,1600,90

      # External monitor
      monitorrule=HDMI-A-1,0.55,1,tile,0,1.0,2560,0,1920,1080,60

      # keyboard
      repeat_rate=25
      repeat_delay=340
      numlockon=1
      xkb_rules_layout=us

      # Trackpad
      disable_trackpad=0
      click_method=0
      tap_to_click=1
      tap_and_drag=1
      drag_lock=1
      mouse_natural_scrolling=0
      trackpad_natural_scrolling=1
      disable_while_typing=1
      left_handed=0
      middle_button_emulation=0
      swipe_min_threshold=1
      accel_profile=2
      accel_speed=0.0
      scroll_method=1


      # Cursor Appearance
      cursor_size=24
      cursor_theme=Bibata-Modern-Classic
      cursor_hide_timeout=0
    '';
  };

  # Sync your user's DankMaterialShell theme with the greeter. You'll probably want this
  configHome = "/home/${username}";

  # Custom config files for non-standard config locations
  configFiles = [
    "/home/${username}/.config/DankMaterialShell/settings.json"
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

# this is a life saver.
# literally no documentation about this anywhere.
# might be good to write about this...
# https://www.reddit.com/r/NixOS/comments/u0cdpi/tuigreet_with_xmonad_how/
systemd.services.dms-greeter.serviceConfig = {
  Type = "idle";
  StandardInput = "tty";
  StandardOutput = "tty";
  StandardError = "journal"; # Without this errors will spam on screen
  # Without these bootlogs will spam on screen
  TTYReset = true;
  TTYVHangup = true;
  TTYVTDisallocate = true;
};

}
