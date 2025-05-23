{ config, pkgs, ... }:

{
  services.nginx.virtualHosts."cache.memes.nz" = {
    enableACME = true;
    forceSSL = true;
    extraConfig = ''
      ignore_invalid_headers off;
      proxy_buffering off;
      client_max_body_size 0;
      access_log /var/log/nginx/atticd-access.log combined;
    '';

    locations."/" = {
      proxyPass = "http://127.0.0.1:5867";
      extraConfig = ''
        chunked_transfer_encoding off;
        proxy_http_version 1.1;
      '';
    };
  };
  services.atticd = {
    enable = true;

    # Replace with absolute path to your credentials file
    #credentialsFile = "/etc/attic/attic.env";
    environmentFile = "/etc/attic/attic.env";

    settings = {
      listen = "[::]:5867";
      database.url = "postgres:///atticd";

      # Data chunking
      #
      # Warning: If you change any of the values here, it will be
      # difficult to reuse existing chunks for newly-uploaded NARs
      # since the cutpoints will be different. As a result, the
      # deduplication ratio will suffer for a while after the change.
      chunking = {
        # The minimum NAR size to trigger chunking
        #
        # If 0, chunking is disabled entirely for newly-uploaded NARs.
        # If 1, all NARs are chunked.
        nar-size-threshold = 64 * 1024; # 64 KiB

        # The preferred minimum size of a chunk, in bytes
        min-size = 16 * 1024; # 16 KiB

        # The preferred average size of a chunk, in bytes
        avg-size = 64 * 1024; # 64 KiB

        # The preferred maximum size of a chunk, in bytes
        max-size = 256 * 1024; # 256 KiB
      };
    };
  };
}
