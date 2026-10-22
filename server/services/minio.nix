{ config, pkgs, ... }:

let
  credentialsFile = "/etc/minio/minio-root-credentials";
  configDir = "/var/lib/minio/config";
  certificatesDir = "/var/lib/minio/certs";
  dataDir = "/mnt/s/minio-data";
in
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

  systemd.tmpfiles.rules = [
    "d '${configDir}' - minio minio - -"
    "d '${dataDir}' - minio minio - -"
  ];

  systemd.services.minio = {
    description = "Minio Object Storage";
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.silo}/bin/minio server --json --address :9745 --console-address :9001 --config-dir=${configDir} --certs-dir=${certificatesDir} ${dataDir}";
      Type = "simple";
      User = "minio";
      Group = "minio";
      LimitNOFILE = 65536;
      EnvironmentFile = credentialsFile;

      # hardening
      DevicePolicy = "closed";
      CapabilityBoundingSet = "";
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
        "AF_NETLINK"
        "AF_UNIX"
      ];
      DeviceAllow = "";
      NoNewPrivileges = true;
      PrivateDevices = true;
      PrivateMounts = true;
      PrivateTmp = true;
      PrivateUsers = true;
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHome = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      MemoryDenyWriteExecute = true;
      LockPersonality = true;
      RemoveIPC = true;
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      SystemCallArchitectures = "native";
      SystemCallFilter = [
        "@system-service"
        "~@privileged"
      ];
      ProtectProc = "invisible";
      ProtectHostname = true;
      UMask = "0077";
      # minio opens /proc/mounts on startup
      ProcSubset = "all";
    };
    environment = {
      MINIO_REGION = "us-east-1";
      MINIO_BROWSER = "on";
    };
  };

  # The service will fail if the credentials file is missing
  systemd.services.minio.unitConfig.ConditionPathExists = credentialsFile;

  # The service will not restart if the credentials file has
  # been changed. This can cause stale root credentials.
  systemd.paths.minio-root-credentials = {
    wantedBy = [ "multi-user.target" ];

    pathConfig = {
      PathChanged = [ credentialsFile ];
      Unit = "minio-restart.service";
    };
  };

  systemd.services.minio-restart = {
    description = "Restart MinIO";

    script = ''
      systemctl restart minio.service
    '';

    serviceConfig = {
      Type = "oneshot";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };

  users.users.minio = {
    group = "minio";
    uid = config.ids.uids.minio;
  };

  users.groups.minio.gid = config.ids.uids.minio;
}
