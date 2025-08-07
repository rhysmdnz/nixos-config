{ config, pkgs, ... }:

{
  systemd.services.keycloak.serviceConfig = {
    Type = "notify";
    AmbientCapabilities = pkgs.lib.mkForce "CAP_SYS_ADMIN,CAP_NET_BIND_SERVICE";
    NotifyAccess = "all";
  };
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
      (pkgs.callPackage ../packages/keycloak-bcrypt { })
      (pkgs.callPackage ../packages/keycloak-systemd-notify { })
    ];
    package = pkgs.keycloak.override { extraFeatures = [ "passkeys" ]; };
    settings.hostname = "account.memes.nz";
    settings.proxy-headers = "xforwarded";
    settings.http-enabled = true;
    settings.http-port = 7812;
    settings.http-management-port = 7813;
    database.passwordFile = "/etc/keycloak/db_password";
  };
}
