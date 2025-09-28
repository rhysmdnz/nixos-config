{ config, pkgs, ... }:
{

  services.nginx.virtualHosts."memes.nz" = {
    enableACME = true;
    forceSSL = true;
    default = true;
    http3 = true;
    quic = true;

    locations."/".root = ./src;
    locations."/".extraConfig = ''
      add_header Access-Control-Allow-Origin *;
      add_header Strict-Transport-Security $hsts_header;
    '';

    locations."/.well-known/host-meta".extraConfig = ''
      return 301 https://social.memes.nz$request_uri;
    '';

    locations."/.well-known/webfinger".extraConfig = ''
      add_header 'Access-Control-Allow-Origin' '*';
      js_content http.webfinger;
    '';

    locations."= /.well-known/matrix/server".extraConfig =
      let
        # use 443 instead of the default 8448 port to unite
        # the client-server and server-server port for simplicity
        server = {
          "m.server" = "matrix.memes.nz:443";
        };
      in
      ''
        add_header Content-Type application/json;
        return 200 '${builtins.toJSON server}';
      '';
    locations."= /.well-known/matrix/client".extraConfig =
      let
        client = {
          "m.homeserver" = {
            "base_url" = "https://matrix.memes.nz";
          };
          "m.identity_server" = {
            "base_url" = "https://vector.im";
          };
          "org.matrix.msc2965.authentication" = {
            "issuer" = "https://matrix-auth.memes.nz/";
            "account" = "https://matrix-auth.memes.nz/account";
          };
        };
      in
      # ACAO required to allow element-web on any URL to request this json file
      ''
        add_header Content-Type application/json;
        add_header Access-Control-Allow-Origin *;
        return 200 '${builtins.toJSON client}';
      '';
  };

  services.nginx.virtualHosts."sharlot.memes.nz" = {
    enableACME = true;
    forceSSL = true;

    locations."/".root = "/web/sharlot/public_html";
    locations."/".extraConfig = "autoindex on;";
  };
}
