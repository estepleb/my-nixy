{
  config,
  lib,
  ...
}: {
    programs.foot = {
      enable = true;


      settings = {
        main = {
          term = "foot";
          shell = "fish";
          pad = "15x15";
          selection-target = "clipboard";
          scrollback-up-page = "Page_Up KP_Page_Up";
          scrollback-down-page = "Page_Down KP_Page_Down";
          clipboard-paste = "Control+v";
          font-increase = "Control+plus Control+equal Control+KP_Add";
          font-decrease = "Control+minus Control+KP_Subtract";
          font-reset = "Control+0 Control+KP_0";
          spawn-terminal = "Control+Shift+n";

        };

        scrollback = {
          lines = 10000;
        };
      };
    };
  }
