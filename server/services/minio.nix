{ config, pkgs, ... }:

{

  services.nginx.virtualHosts."nix-cache.memes.nz" = {
    enableACME = true;
    forceSSL = true;
    extraConfig = ''
      ignore_invalid_headers off;
      proxy_buffering off;
      client_max_body_size 0;
    '';

    locations."/" = {
      proxyPass = "http://127.0.0.1:9745";
      extraConfig = ''
        chunked_transfer_encoding off;
        proxy_http_version 1.1;
      '';
    };
  };

  services.minio.enable = true;
  services.minio.listenAddress = ":9745";
  services.minio.rootCredentialsFile = "/etc/minio/minio-root-credentials";
  services.minio.dataDir = [ "/mnt/s/minio-data" ];
}
