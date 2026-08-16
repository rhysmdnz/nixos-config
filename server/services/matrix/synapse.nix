{ config, pkgs, ... }:
let
  matrix_port = 8008;
  matrix_metrics_port = 9000;
in
{

  services.nginx.virtualHosts."matrix.memes.nz" = {
    enableACME = true;
    forceSSL = true;
    extraConfig = ''
      access_log /var/log/nginx/matrix-access.log combined;
    '';

    locations."/".extraConfig = ''
      return 404;
    '';

    locations."~ ^/_matrix/client/(.*)/(login|logout|refresh)" = {
      proxyPass = "http://127.0.0.1:7199";
    };

    locations."/metrics" = {
      proxyPass = "http://127.0.0.1:${toString matrix_metrics_port}";
    };

    locations."/_matrix" = {
      proxyPass = "http://127.0.0.1:${toString matrix_port}";
    };

    locations."/_synapse" = {
      proxyPass = "http://127.0.0.1:${toString matrix_port}";
    };
  };

  services.matrix-synapse = {
    enable = true;

    extraConfigFiles = [ "/etc/synapse/secrets" ];

    plugins = with config.services.matrix-synapse.package.plugins; [
      pkgs.python3Packages.authlib
      matrix-synapse-s3-storage-provider
    ];

    settings = {
      server_name = "memes.nz";
      public_baseurl = "https://matrix.memes.nz";

      password_config.enabled = false;

      experimental_features.msc4108_enabled = true;
      matrix_authentication_service = {
        enabled = true;
        endpoint = "https://matrix-auth.memes.nz";
      };

      listeners = [
        {
          port = matrix_port;
          bind_addresses = [ "127.0.0.1" ];
          type = "http";
          tls = false;
          x_forwarded = true;
          resources = [
            {
              names = [
                "client"
                "federation"
              ];
              compress = false;
            }
          ];
        }
        {
          type = "metrics";
          port = matrix_metrics_port;
          bind_addresses = [ "127.0.0.1" ];
          tls = false;
          x_forwarded = true;
          resources = [
            {
              names = [
                "client"
                "federation"
              ];
              compress = false;
            }
          ];
        }
      ];

      url_preview_enabled = true;
      enable_registration = false;
      enable_metrics = true;

      database.allow_unsafe_locale = true;
      database.args = {
        database = "synapse";
      };

      app_service_config_files = [ "/var/lib/matrix-appservice-irc/registration.yml" ];

      media_storage_providers = [
        {
          module = "s3_storage_provider.S3StorageProviderBackend";
          store_local = true;
          store_remote = true;
          store_synchronous = true;
          config = {
            bucket = "matrix-media";
            endpoint_url = "http://localhost:9745";
          };
        }
      ];
    };
  };
}
