{
  # https://github.com/anotherhadi/nixy
  description = ''
    Nixy simplifies and unifies the Hyprland ecosystem with a modular, easily customizable setup.
    It provides a structured way to manage your system configuration and dotfiles with minimal effort.
  '';

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    mac-style-plymouth.url = "github:SergioRibera/s4rchiso-plymouth-theme";
    stylix.url = "github:danth/stylix";
    apple-fonts.url = "github:Lyndeno/apple-fonts.nix";
    nixcord.url = "github:kaylorben/nixcord";
    sops-nix.url = "github:Mic92/sops-nix";
    nixarr.url = "github:rasmus-kirk/nixarr";
    nvf.url = "github:notashelf/nvf";
    vicinae.url = "github:vicinaehq/vicinae";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mango = {
          url = "github:DreamMaoMao/mango";
          inputs.nixpkgs.follows = "nixpkgs";
        };
    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
        };
    quickshell = {
      url = "git+https://git.outfoxxed.me/quickshell/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
        };
    eleakxir.url = "github:anotherhadi/eleakxir";
  };

  outputs = inputs @ { self, nixpkgs, mango, ...}: {
    nixosConfigurations = {
      thinkbook-plus =
        nixpkgs.lib.nixosSystem {
          modules = [
            {
              nixpkgs.overlays = [
           	    inputs.mac-style-plymouth.overlays.default
              ];
              _module.args = {
                inherit inputs;
              };
            }
            inputs.home-manager.nixosModules.home-manager
            inputs.stylix.nixosModules.stylix
            inputs.mango.nixosModules.mango
            ./hosts/thinkbook-plus/configuration.nix # CHANGEME: change the path to match your host folder
          ];
        };
      # Jack is my server
      jack = nixpkgs.lib.nixosSystem {
        modules = [
          {_module.args = {inherit inputs;};}
          inputs.home-manager.nixosModules.home-manager
          inputs.stylix.nixosModules.stylix
          inputs.sops-nix.nixosModules.sops
          inputs.nixarr.nixosModules.default
          inputs.eleakxir.nixosModules.eleakxir
          ./hosts/server/configuration.nix
        ];
      };
    };
  };
}
