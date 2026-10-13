{ pkgs, ... }:

{
  services.nginx = {
    enable = true;
    enableReload = true;
    # package = pkgs.nginxQuic;
    recommendedTlsSettings = true;
    sslProtocols = "TLSv1.3";
    sslCiphers = null;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedBrotliSettings = true;
    recommendedProxySettings = true;

    additionalModules = [ pkgs.nginxModules.njs ];

    resolver.addresses = [ "127.0.0.53" ];

    commonHttpConfig = ''
      js_import http from ${./mastodon/http.js};
      js_fetch_trusted_certificate /etc/ssl/certs/ca-certificates.crt;

      proxy_cache_path /tmp/nginx_mstdn_media levels=1:2 keys_zone=mastodon_media:100m max_size=1g inactive=24h;
    '';

    appendHttpConfig = ''
      # Add HSTS header with preloading to HTTPS requests.
      # Adding this header to HTTP requests is discouraged
      map $scheme $hsts_header {
          https   "max-age=63072000; includeSubdomains; preload";
      }
      add_header Strict-Transport-Security $hsts_header;
    '';

    virtualHosts = {
      "johnguant.com" = {
        enableACME = true;
        forceSSL = true;
        globalRedirect = "memes.nz";
        http3 = true;
        quic = true;
      };
    };
  };

  # services.nginx.package = pkgs.nginxStable.overrideAttrs {
  #  CFLAGS = "-Wno-error=discarded-qualifiers";
  # };

  users.users.nginx.extraGroups = [ "mastodon" ];

  networking.firewall = {
    allowedTCPPorts = [
      80
      443
    ];
    allowedUDPPorts = [ 443 ];
  };
}
