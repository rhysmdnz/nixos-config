{
  config,
  pkgs,
  ...
}:

{
  systemd.services.keycloak.after = [ "postgresql.target" ];
  systemd.services.keycloak.bindsTo = [ "postgresql.target" ];
  services.nginx.virtualHosts."account.memes.nz" = {
    enableACME = true;
    forceSSL = true;

    locations."= /" = {
      return = "https://account.memes.nz/realms/master/account/";
    };

    locations."/" = {
      proxyPass = "http://localhost:${toString config.services.keycloak.settings.http-port}";
    };
  };
  services.keycloak = {
    enable = true;
    plugins = [
      pkgs.keycloak.plugins.junixsocket-common
      pkgs.keycloak.plugins.junixsocket-native-common
    ];
    package = pkgs.keycloak.override { extraFeatures = [ "passkeys" ]; };
    settings = {
      hostname = "account.memes.nz";
      proxy-headers = "xforwarded";
      http-enabled = true;
      http-port = 7812;
      http-management-port = 7813;
    };
    database.host = "/run/postgresql";
  };
}
