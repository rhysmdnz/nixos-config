{
  config,
  pkgs,
  lib,
  ...
}:
{

  services.nginx.virtualHosts."social.memes.nz" = {
    enableACME = true;
    forceSSL = true;
    root = "${pkgs.mastodon}/public/";
    locations."/system/".alias = "/var/lib/mastodon/public-system/";
    locations."/" = {
      tryFiles = "$uri @proxy";
    };
    locations."@proxy" = {
      proxyPass = "http://unix:/run/mastodon-web/web.socket";
      proxyWebsockets = true;
    };
    locations."/api/v1/streaming/" = {
      proxyPass = "http://mastodon-streaming";
      proxyWebsockets = true;
    };
  };
  services.nginx.upstreams.mastodon-streaming = {
    extraConfig = ''
      least_conn;
    '';
    servers = builtins.listToAttrs (
      map
        (i: {
          name = "unix:/run/mastodon-streaming/streaming-${toString i}.socket";
          value = { };
        })
        (lib.range 1 config.services.mastodon.streamingProcesses)
    );
  };

  services.nginx.virtualHosts."storage.social.memes.nz" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:9745/mastodon/";
      extraConfig = ''
        limit_except GET {
          deny all;
        }

        proxy_http_version 1.1;

        #proxy_set_header Host nix-cache.memes.nz;
        proxy_set_header Connection ''';
        proxy_set_header Authorization ''';
        proxy_hide_header Set-Cookie;
        proxy_hide_header 'Access-Control-Allow-Origin';
        proxy_hide_header 'Access-Control-Allow-Methods';
        proxy_hide_header 'Access-Control-Allow-Headers';
        proxy_hide_header x-amz-id-2;
        proxy_hide_header x-amz-request-id;
        proxy_hide_header x-amz-meta-server-side-encryption;
        proxy_hide_header x-amz-server-side-encryption;
        proxy_hide_header x-amz-bucket-region;
        proxy_hide_header x-amzn-requestid;
        proxy_ignore_headers Set-Cookie;
        proxy_intercept_errors off;

        proxy_cache mastodon_media;
        proxy_cache_valid 200 48h;
        proxy_cache_use_stale error timeout updating http_500 http_502 http_503 http_504;
        proxy_cache_lock on;

        expires 1y;
        add_header Cache-Control public;
        add_header 'Access-Control-Allow-Origin' '*';
        add_header X-Cache-Status $upstream_cache_status;
      '';
    };
  };

  services.mastodon.enable = true;
  services.mastodon.streamingProcesses = 5;
  services.mastodon.localDomain = "memes.nz";
  services.mastodon.smtp.fromAddress = "mastodon@memes.nz";
  services.mastodon.enableUnixSocket = true;
  services.mastodon.elasticsearch.host = "127.0.0.1";
  services.mastodon.extraEnvFiles = [ "/var/lib/mastodon/secret-env" ];
  services.mastodon.extraConfig = {
    WEB_DOMAIN = "social.memes.nz";
    OIDC_ENABLED = "true";
    OIDC_DISPLAY_NAME = "MemesNZ Account";
    OIDC_ISSUER = "https://account.memes.nz/realms/master";
    OIDC_DISCOVERY = "true";
    OIDC_SCOPE = "openid,profile";
    OIDC_UID_FIELD = "preferred_username";
    OIDC_CLIENT_ID = "mastodon";
    OIDC_REDIRECT_URI = "https://social.memes.nz/auth/auth/openid_connect/callback";
    OIDC_SECURITY_ASSUME_EMAIL_IS_VERIFIED = "true";
    OMNIAUTH_ONLY = "true";
    ONE_CLICK_SSO_LOGIN = "true";
    S3_ENABLED = "true";
    S3_BUCKET = "mastodon";
    S3_ALIAS_HOST = "storage.social.memes.nz";
    S3_HOSTNAME = "nix-cache.memes.nz";
    S3_ENDPOINT = "https://nix-cache.memes.nz";
    AWS_ACCESS_KEY_ID = "1ZH4qoHKpNbdFHpTEKzc";
  };
  systemd.services.mastodon-search-index = {
    description = "Mastodon search index update";
    environment = config.systemd.services.mastodon-media-auto-remove.environment;
    serviceConfig = {
      Type = "oneshot";
      EnvironmentFile = "/var/lib/mastodon/.secrets_env";
      User = config.services.mastodon.user;
      Group = config.services.mastodon.group;
      # State directory and mode
      StateDirectory = "mastodon";
      StateDirectoryMode = "0750";
      # Logs directory and mode
      LogsDirectory = "mastodon";
      LogsDirectoryMode = "0750";
      # Proc filesystem
      ProcSubset = "pid";
      ProtectProc = "invisible";
      # Access write directories
      UMask = "0027";
      # Capabilities
      CapabilityBoundingSet = "";
      # Security
      NoNewPrivileges = true;
      # Sandboxing
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      PrivateDevices = true;
      PrivateUsers = true;
      ProtectClock = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectControlGroups = true;
      RestrictAddressFamilies = [
        "AF_UNIX"
        "AF_INET"
        "AF_INET6"
        "AF_NETLINK"
      ];
      RestrictNamespaces = true;
      LockPersonality = true;
      MemoryDenyWriteExecute = false;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      RemoveIPC = true;
      PrivateMounts = true;
      # System Call Filtering
      SystemCallArchitectures = "native";
    };
    script = ''
      ${config.services.mastodon.package}/bin/tootctl search deploy
    '';
    startAt = "*-*-* *:00:00";
  };

  systemd.services.mastodon-init-dirs.after = [
    "keycloak.service"
    "nginx.service"
    "network-online.target"
  ];
  systemd.services.mastodon-init-dirs.requires = [ "network-online.target" ];

  users.users.mastodon-media-backup = {
    group = "mastodon-media-backup";
    isSystemUser = true;
  };

  users.groups.mastodon-media-backup = { };

  #systemd.services.mastodon-media-backup = {
  #  description = "Mastodon to backblaze b2 sync";

  #  wantedBy = [ "multi-user.target" ];
  #  after = [
  #    "network.target"
  #    "minio.service"
  #  ];

    #confinement.enable = true;

  #  serviceConfig = {
  #    ExecStart = "${pkgs.minio-client}/bin/mc --config-dir /etc/mc-b2 mirror --exclude '*cache/*' --watch --remove local/mastodon b2/memesnz-mastodon-backup --json";
  #    ConfigurationDirectory = "mc-b2";
  #    User = "mastodon-media-backup";
  #    Group = "mastodon-media-backup";
  #    Restart = "always";

      # Confinement
  #    ProtectSystem = "strict";
  #    PrivateDevices = true;
  #    PrivateTmp = true;
  #    PrivateUsers = true;
  #    ProtectControlGroups = true;
   #   ProtectKernelModules = true;
    #  ProtectKernelTunables = true;

  #    ProcSubset = "pid";
  #    ProtectHome = true;
   #   ProtectClock = true;
   #   ProtectHostname = true;
   #   ProtectKernelLogs = true;
   #   ProtectProc = "invisible";
   #   RestrictNamespaces = true;
   #   LockPersonality = true;
      #MemoryDenyWriteExecute = false;
   #   RestrictRealtime = true;
   #   RestrictSUIDSGID = true;
   #   RestrictAddressFamilies = [
   #     "AF_INET"
   #     "AF_INET6"
   #   ];
   #   RemoveIPC = true;
      ## System Call Filtering
   #   SystemCallArchitectures = "native";
   #   SystemCallFilter = "~@mount @clock @cpu-emulation @debug @module @obsolete @privileged @raw-io @reboot @swap";
      ## Security
    #  NoNewPrivileges = true;

   #   CapabilityBoundingSet = "";
   # };
  #};
}
