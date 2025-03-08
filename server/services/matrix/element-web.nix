{ config, pkgs, ... }:

{

  services.nginx.virtualHosts."chat.memes.nz" = {
    enableACME = true;
    forceSSL = true;
    root = pkgs.element-web.override {
      conf = {
        default_server_name = "memes.nz";
        disable_custom_urls = true;
        sso_redirect_options = {
          immediate = false;
          on_welcome_page = true;
        };
        setting_defaults."UIFeature.registration" = false;
        showLabsSettings = true;
        roomDirectory = {
          "servers" = [
            "matrix.org"
            "mozilla.org"
          ];
        };
      };
    };
  };
}
