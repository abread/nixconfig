{
  config,
  pkgs,
  ...
}: {
  # Flatpak applications cannot follow symlinks to the nix store, so we create bindmounts to resolve them transparently
  system.fsPackages = [pkgs.bindfs];
  fileSystems = let
    mkRoSymBind = path: {
      device = path;
      fsType = "fuse.bindfs";
      options = ["ro" "resolve-symlinks" "x-gvfs-hide"];
    };

    # Fonts need a full env for reasons I no longer recall
    aggregatedFonts = pkgs.buildEnv {
      name = "system-fonts";
      paths = config.fonts.packages;
      pathsToLink = ["/share/fonts"];
    };
  in {
    # Create an FHS mount to support flatpak host icons/fonts/wtv
    #"/usr/share/applications" = mkRoSymBind (config.system.path + "/share/applications");
    "/usr/share/icons" = mkRoSymBind (config.system.path + "/share/icons");
    "/usr/share/fonts" = mkRoSymBind (aggregatedFonts + "/share/fonts");
  };
}