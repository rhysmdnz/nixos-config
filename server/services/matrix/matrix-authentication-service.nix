{ config, pkgs, ... }:

{

  services.nginx.virtualHosts."matrix-auth.memes.nz" = {
    enableACME = true;
    forceSSL = true;

    locations."/" = {
      proxyPass = "http://localhost:7199";
      extraConfig = ''
        proxy_http_version 1.1;
      '';
    };
  };

  services.matrix-authentication-service = {
    enable = true;

    extraConfigFiles = [ "/opt/matrix-authentication-service/config.yaml" ];

    serviceDependencies = [ "postgresql.service" ];

    settings = {
      http.public_base = "https://matrix-auth.memes.nz/";
      http.issuer = "https://matrix-auth.memes.nz/";
      http.trusted_proxies = [
        "192.128.0.0/16"
        "172.16.0.0/12"
        "10.0.0.0/10"
        "127.0.0.1/8"
        "fd00::/8"
        "::1/128"
      ];
      http.listeners = [
        {
          name = "web";
          resources = [
            { name = "discovery"; }
            { name = "human"; }
            { name = "oauth"; }
            { name = "compat"; }
            {
              name = "graphql";
              playground = true;
            }
            {
              name = "assets";
              path = "${pkgs.matrix-authentication-service}/share/matrix-authentication-service/assets/";
            }
          ];
          binds = [ { address = "[::]:7199"; } ];
          proxy_protocol = false;
        }
        {
          name = "internal";
          resources = [ { name = "health"; } ];
          binds = [
            {
              host = "localhost";
              port = 7198;
            }
          ];
          proxy_protocol = false;
        }
      ];

      matrix.homeserver = "memes.nz";
      matrix.endpoint = "https://matrix.memes.nz/";

      passwords.enabled = false;
    };
  };
}
