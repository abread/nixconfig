{
  config,
  lib,
  pkgs,
  profiles,
  ...
}:
let
  domain = "findi.breda.pt";
  fireflyUrl = "https://fin.breda.pt";
in
{
  imports = [
    profiles.webserver
  ];

  services.firefly-iii-data-importer = {
    enable = true;
    enableNginx = true;
    virtualHost = domain;
    settings = {
      APP_ENV = "production";
      APP_URL = "https://${domain}"; # not used by anything supposedly but oh well

      FIREFLY_III_URL = fireflyUrl;
      VANITY_URL = fireflyUrl;

      IMPORT_DIR_ALLOWLIST = "${config.services.firefly-iii-data-importer.dataDir}/import";

      TZ = config.time.timeZone;
      EXPECT_SECURE_URL = "true";
      # TODO: email (?)

      APP_KEY_FILE = "${config.services.firefly-iii-data-importer.dataDir}/app_key.env";
      FIREFLY_III_ACCESS_TOKEN_FILE = "${config.services.firefly-iii-data-importer.dataDir}/firefly_iii_access_token.env";
      NORDIGEN_ID_FILE = "${config.services.firefly-iii-data-importer.dataDir}/nordigen_id.env";
      NORDIGEN_KEY_FILE = "${config.services.firefly-iii-data-importer.dataDir}/nordigen_key.env";
    };
  };

  security.acme.certs."${domain}" = { };
  services.nginx.virtualHosts."${domain}" = {
    useACMEHost = domain;
    forceSSL = true;
  };

  systemd.services."phpfpm-firefly-iii-data-importer" = {
    requires = [
      "phpfpm-firefly-iii.service"
      "nginx.service"
    ];
    after = [
      "phpfpm-firefly-iii.service"
      "postgresql.service"
      "nginx.service"
    ];
  };

  systemd.services."phpfpm-firefly-iii-data-importer".serviceConfig =
    let
      envFileLocation = "/run/phpfpm-firefly-iii-data-importer.env";
      env-file-values =
        lib.attrsets.mapAttrs' (n: v: lib.attrsets.nameValuePair (lib.strings.removeSuffix "_FILE" n) v)
          (
            lib.attrsets.filterAttrs (
              n: _v: lib.strings.hasSuffix "_FILE" n
            ) config.services.firefly-iii-data-importer.settings
          );
    in
    {
      EnvironmentFile = "-${envFileLocation}";
      ExecStartPre = pkgs.writeShellScript "data-importer-gen-env.sh" ''
        rm '${envFileLocation}'
        umask 377
        ${lib.strings.concatLines (
          lib.attrsets.mapAttrsToList (
            n: v: "echo \"${n}='$(< '${v}')'\" >> '${envFileLocation}'"
          ) env-file-values
        )}
      '';
    };
  services.phpfpm.pools."firefly-iii-data-importer".phpEnv =
    let
      env-file-values =
        lib.attrsets.mapAttrs'
          (
            n: _v:
            lib.attrsets.nameValuePair (lib.strings.removeSuffix "_FILE" n) (
              "$" + (lib.strings.removeSuffix "_FILE" n)
            )
          )
          (
            lib.attrsets.filterAttrs (
              n: _v: lib.strings.hasSuffix "_FILE" n
            ) config.services.firefly-iii-data-importer.settings
          );
      env-nonfile-values = lib.attrsets.filterAttrs (
        n: _v: !lib.strings.hasSuffix "_FILE" n
      ) config.services.firefly-iii-data-importer.settings;
    in
    env-file-values // env-nonfile-values;

  systemd.services."firefly-iii-data-importer-autoimport" = {
    description = "Firefly III Data Importer Auto Import";
    requires = [
      "nginx.service"
      "phpfpm-firefly-iii-data-importer.service"
    ];
    after = [
      "nginx.service"
      "phpfpm-firefly-iii-data-importer.service"
    ];

    serviceConfig = {
      Type = "oneshot";
      User = config.services.firefly-iii-data-importer.user;
      Group = config.services.firefly-iii-data-importer.group;
    };
    script = ''
      shopt -s globstar

      . ${config.systemd.services.firefly-iii-data-importer-setup.serviceConfig.ExecStart}

      for f in '${config.services.firefly-iii-data-importer.dataDir}/import'/**/*.json; do
        ${config.services.firefly-iii-data-importer.package}/artisan importer:import "$(realpath "$f")"
      done
    '';
  };
  systemd.timers."firefly-iii-data-importer-autoimport" = {
    unitConfig.Description = "Firefly III Data Importer Auto Import";
    timerConfig = {
      OnUnitInactiveSec = "6h"; # run every 6h (4x / day)
      RandomizedDelaySec = "2min";
      AccuracySec = "2min";
      Persistent = "true";
    };
    wantedBy = [ "timers.target" ];
  };

  # TODO: backups?
}
