{
  config,
  lib,
  ...
}: {

  config.var = {
    hostname = "nix-vm";
    username = "estepleb";
    tailnet = "bullhead-komodo.ts.net";
    secretsDirectory = "/home/"
          + config.var.username
          + "/.config/nixos/hosts/nix-vm/secrets/sops-files";
          
    configDirectory =
      "/home/"
      + config.var.username
      + "/.config/nixos"; # The path of the nixos configuration directory

    keyboardLayout = "us";

    location = "Washington DC";
    timeZone = "America/New_York";
    defaultLocale = "en_US.UTF-8";
    extraLocale = "en_US.UTF-8";

    git = {
      username = "estepleb";
      email = "tallis.estevez1@gmail.com";
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
