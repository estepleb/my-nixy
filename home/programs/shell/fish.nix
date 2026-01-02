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
      m = "micro";
      c = "clear";
      clera = "clear";
      celar = "clear";
      e = "exit";
      cd = "z";
      sl = "ls";
      mkdir = "mkdir -p";
      cp = "cp -v";
      mv = "mv -v";

      obsidian-no-gpu = "env ELECTRON_OZONE_PLATFORM_HINT=auto obsidian --ozone-platform=x11";

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

    shellAliases = {
      ls = "eza -al --color=always --group-directories-first --icons=always --no-quotes";
      la = "eza -a --color=always --group-directories-first --icons=always --no-quotes";
      ll = "eza -l --color=always --group-directories-first --icons=always --no-quotes";
      tree = "eza -aT --color=always --group-directories-first --icons=always --no-quotes";
      l. = "eza -a | grep -e '^\.'"
      open = "${pkgs.xdg-utils}/bin/xdg-open";
      cat = "bat --theme=base16 --color=always --paging=never --tabs=2 --wrap=never --plain";
    }
    shellInit =
    ''
      function fish_greeting
          fastfetch
      end

      # Format man pages
      set -x MANROFFOPT "-c"
      set -x MANPAGER "sh -c 'col -bx | bat -l man -p'"

      # Set settings for https://github.com/franciscolourenco/done
      set -U __done_min_cmd_duration 10000
      set -U __done_notification_urgency_level low

      ## Environment setup
      # Apply .profile: use this to put fish compatible .profile stuff in
      if test -f ~/.fish_profile
        source ~/.fish_profile
      end

      # Add ~/.local/bin to PATH
      if test -d ~/.local/bin
          if not contains -- ~/.local/bin $PATH
              set -p PATH ~/.local/bin
          end
      end

      # Add depot_tools to PATH
      if test -d ~/Applications/depot_tools
          if not contains -- ~/Applications/depot_tools $PATH
              set -p PATH ~/Applications/depot_tools
          end
      end


      ## Functions
      # Functions needed for !! and !$ https://github.com/oh-my-fish/plugin-bang-bang
      function __history_previous_command
        switch (commandline -t)
        case "!"
          commandline -t $history[1]; commandline -f repaint
        case "*"
          commandline -i !
        end
      end

      function __history_previous_command_arguments
        switch (commandline -t)
        case "!"
          commandline -t ""
          commandline -f history-token-search-backward
        case "*"
          commandline -i '$'
        end
      end

      if [ "$fish_key_bindings" = fish_vi_key_bindings ];
        bind -Minsert ! __history_previous_command
        bind -Minsert '$' __history_previous_command_arguments
      else
        bind ! __history_previous_command
        bind '$' __history_previous_command_arguments
      end

      # Fish command history
      function history
          builtin history --show-time='%F %T '
      end

      function backup --argument filename
          cp $filename $filename.bak
      end

      # Copy DIR1 DIR2
      function copy
          set count (count $argv | tr -d \n)
          if test "$count" = 2; and test -d "$argv[1]"
              set from (echo $argv[1] | trim-right /)
              set to (echo $argv[2])
              command cp -r $from $to
          else
              command cp $argv
          end
      end

      '';
  };
}
