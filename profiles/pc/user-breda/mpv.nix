{ pkgs, ... }:
{
  programs.mpv = {
    enable = true;
    bindings = {
      r = "cycle_values video-rotate 90 180 270 0";
    };
    config = {
      vo = "dmabuf-wayland";
      hwdec = "auto-safe";
    };

    scripts = with pkgs.mpvScripts; [
      mpris
      autosubsync-mpv
      # TODO: autosub (?)
    ];
    scriptOpts = {
      autosubsync = {
        # keep old subs
        unload_old_sub = "no";
      };
    };
  };
}
