{ ... }:
{
  services.kanshi = {
    enable = true;

    settings = [
      {
        profile = {
          name = "default";
          outputs = [
            {
              criteria = "eDP-1";
              status = "enable";
              position = "0,0";
            }
          ];
        };
      }
      {
        profile = {
          name = "rnl";
          outputs = [
            {
              criteria = "Iiyama North America PL3293UH 1213432400569";
              status = "enable";
              position = "0,0";
              scale = 1.2;
            }
            {
              criteria = "eDP-1";
              status = "enable";
              position = "640,1801";
            }
          ];
          exec = "swaymsg workspace 2, move workspace to 'Iiyama North America PL3293UH 1213432400569', workspace 3, move workspace to 'Iiyama North America PL3293UH 1213432400569'";
        };
      }
      {
        profile = {
          name = "rnl2";
          outputs = [
            {
              criteria = "Iiyama North America PL3293UH 1213432400967";
              status = "enable";
              position = "0,0";
              scale = 1.2;
            }
            {
              criteria = "eDP-1";
              status = "enable";
              position = "640,1801";
            }
          ];
          exec = "swaymsg workspace 2, move workspace to 'Iiyama North America PL3293UH 1213432400967', workspace 3, move workspace to 'Iiyama North America PL3293UH 1213432400967'";
        };
      }
      {
        profile = {
          name = "rnl3";
          outputs = [
            {
              criteria = "Iiyama North America PL3293UH 1213432700309";
              status = "enable";
              position = "0,0";
              scale = 1.2;
            }
            {
              criteria = "eDP-1";
              status = "enable";
              position = "640,1801";
            }
          ];
          exec = "swaymsg workspace 2, move workspace to 'Iiyama North America PL3293UH 1213432700309', workspace 3, move workspace to 'Iiyama North America PL3293UH 1213432700309'";
        };
      }
    ];
  };
}
