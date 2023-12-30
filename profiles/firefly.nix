{
  config,
  inputs,
  profiles,
  ...
}: let
  dbName = "firefly-iii";
  domain = "fin.breda.pt";
in {
  imports = [
    profiles.webserver
    profiles.postgres
  ];

  services.firefly-iii = {
    enable = true;
    enableNginx = true;
    virtualHost = domain;
    settings = {
      APP_ENV = "production";
      APP_KEY_FILE = "${config.services.firefly-iii.dataDir}/app_key.env";
      SITE_OWNER = inputs.hidden.robotsEmail "firefly-${config.networking.hostname}";
      DEFAULT_LOCALE = "pt_PT";
      TZ = config.time.timeZone;

      DB_CONNECTION = "pgsql";
      DB_HOST = "/run/postgresql"; # socket dir
      DB_PORT = 5432; # postgres is weird with sockets
      DB_USERNAME = config.services.firefly-iii.user;
      DB_DATABASE = dbName;
    };
  };

  security.acme.certs."${domain}" = {};
  services.nginx.virtualHosts."${domain}" = {
    useACMEHost = domain;
    forceSSL = true;
  };

  services.postgresql.ensureDatabases = [dbName];
  services.postgresql.ensureUsers = [
    {
      name = config.services.firefly-iii.user;
      ensureDBOwnership = true;
    }
  ];

  # TODO: backup ${dataDir}/storage/upload (or just the whole dataDir) and DB
}
