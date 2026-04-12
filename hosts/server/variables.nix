{
  config,
  lib,
  ...
}: {

  config.var = {
    hostname = "docker-vm";
    username = "estepleb";
    configDirectory =
      "/home/"
      + config.var.username
      + "/.config/nixos"; # The path of the nixos configuration directory

    keyboardLayout = "fr";

    location = "Paris";
    timeZone = "America/New_York";
    defaultLocale = "en_US.UTF-8";
    extraLocale = "en_US.UTF-8";

    git = {
      username = "estepleb";
      email = "112569860+anotherhadi@users.noreply.github.com";
    };

    autoUpgrade = true;
    autoGarbageCollector = true;
  };

  # Let this here
  options = {
    var = lib.mkOption {
      type = lib.types.attrs;
      default = {};
    };
  };
}
