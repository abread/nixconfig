{
  config,
  profiles,
  ...
}: let
  domain = "findi.breda.pt";
  fireflyUrl = "https://fin.breda.pt";
in {
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
      FIREFLY_III_ACCESS_TOKEN_FILE = "${config.services.firefly-iii-data-importer.dataDir}/nordigen_key.env";
      NORDIGEN_ID_FILE = "${config.services.firefly-iii-data-importer.dataDir}/nordigen_id.env";
      NORDIGEN_KEY_FILE = "${config.services.firefly-iii-data-importer.dataDir}/nordigen_key.env";
    };
  };

  security.acme.certs."${domain}" = {};
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

  systemd.services."firefly-iii-data-importer-autoimport" = {
    description = "Firefly III Data Importer Auto Import";
    requires = ["nginx.service" "phpfpm-firefly-iii-data-importer.service"];
    after = ["nginx.service" "phpfpm-firefly-iii-data-importer.service"];

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
    wantedBy = ["timers.target"];
  };

  # TODO: backups?
}
