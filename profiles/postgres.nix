{pkgs, ...}: {
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16;

    authentication = ''
      local sameuser all  peer map=superuser_map
    '';
    enableTCPIP = false;

    identMap = ''
      # ArbitraryMapName systemUser DBUser
      superuser_map      root      postgres
      superuser_map      postgres  postgres

      # Let other names login as themselves
      superuser_map      /^(.*)$   \1
    '';
  };

  # TODO: backup
}
