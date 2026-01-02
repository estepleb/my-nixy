# My shell configuration
{
  pkgs,
  lib,
  config,
  ...
}: let
  fetch = config.theme.fetch; # neofetch, nerdfetch, pfetch
in {
  home.packages = with pkgs; [bat ripgrep tldr sesh];

  programs.fish = {
    enable = true;
    generateCompletions = true;

    shellAbbrs = {
      vim = "nvim";
      vi = "nvim";
      v = "nvim";
      m = "micro";
      c = "clear";
      clera = "clear";
      celar = "clear";
      e = "exit";
      cd = "z";
      ls = "eza --icons=always --no-quotes";
      tree = "eza --icons=always --tree --no-quotes";
      sl = "ls";
      open = "${pkgs.xdg-utils}/bin/xdg-open";
      icat = "${pkgs.kitty}/bin/kitty +kitten icat";
      cat = "bat --theme=base16 --color=always --paging=never --tabs=2 --wrap=never --plain";
      mkdir = "mkdir -p";

      obsidian-no-gpu = "env ELECTRON_OZONE_PLATFORM_HINT=auto obsidian --ozone-platform=x11";
      wireguard-import = "nmcli connection import type wireguard file";

      notes = "nvim ~/notes/index.md --cmd 'cd ~/notes' -c ':lua Snacks.picker.smart()'";
      note = "notes";
      tmp = "nvim /tmp/$(date | sed 's/ //g;s/\\.//g').md";

      nix-shell = "nix-shell --command fish";

      # git
      g = "lazygit";
      ga = "git add";
      gc = "git commit";
      gcu = "git add . && git commit -m 'Update'";
      gp = "git push";
      gpl = "git pull";
      gs = "git status";
      gd = "git diff";
      gco = "git checkout";
      gcb = "git checkout -b";
      gbr = "git branch";
      grs = "git reset HEAD~1";
      grh = "git reset --hard HEAD~1";

      gaa = "git add .";
      gcm = "git commit -m";
    };

    shellInit =
      # bash
      ''
        bindkey -e
        ${
          if fetch == "neofetch"
          then pkgs.neofetch + "/bin/neofetch"
          else if fetch == "nerdfetch"
          then "nerdfetch"
          else if fetch == "pfetch"
          then "echo; ${pkgs.pfetch}/bin/pfetch"
          else ""
        }

      '';
  };
}
