{ config, pkgs, ... }:

let
  #  matrix-authentication-service = pkgs.callPackage ../../packages/matrix-authentication-service { };
  format = pkgs.formats.yaml { };
  configFile = format.generate "config.yaml" {
    http = {
      listeners = [
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
    };
  };
in
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

  users.users.matrix-authentication-service = {
    home = "/home/matrix-authentication-service";
    group = "matrix-authentication-service";
    isSystemUser = true;
  };

  users.groups.matrix-authentication-service = { };

  systemd.services.matrix-authentication-service = {
    description = "MAS daemon";

    wantedBy = [ "multi-user.target" ];
    after = [
      "network.target"
      "postgresql.service"
    ];

    restartIfChanged = true; # set to false, if restarting is problematic

    serviceConfig = {
      User = "matrix-authentication-service";
      Group = "matrix-authentication-service";
      ExecStart = "${pkgs.matrix-authentication-service}/bin/mas-cli server --config /opt/matrix-authentication-service/config.yaml --config ${configFile} --migrate";
      Restart = "always";

      ProtectSystem = "strict";
      PrivateDevices = true;
      PrivateTmp = true;
      PrivateUsers = true;
      ProtectControlGroups = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;

      ProcSubset = "pid";
      ProtectHome = "tmpfs";
      ProtectClock = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectProc = "invisible";
      RestrictNamespaces = true;
      LockPersonality = true;
      #MemoryDenyWriteExecute = false;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
      ];
      RemoveIPC = true;
      ## System Call Filtering
      SystemCallArchitectures = "native";
      SystemCallFilter = "~@mount @clock @cpu-emulation @debug @module @obsolete @privileged @raw-io @reboot @swap";
      ## Security
      NoNewPrivileges = true;

      CapabilityBoundingSet = "";
    };
  };
}
