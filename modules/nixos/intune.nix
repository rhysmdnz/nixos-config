{ config
, pkgs
, lib
, ...
}:
with lib; let
  cfg = config.services.intune;
in
{
  options.services.intune = {
    enable = mkEnableOption "intune";

    identityBrokerPackage = mkOption {
      type = types.package;
      default = pkgs.microsoft-identity-broker;
      defaultText = literalExpression "pkgs.microsoft-identity-broker";
      description = mdDoc ''
        Which identity-broker package to use.
      '';
    };
  };


  config = mkIf cfg.enable {
    users.users.microsoft-identity-broker = {
      group = "microsoft-identity-broker";
      isSystemUser = true;
    };

    users.groups.microsoft-identity-broker = { };
    environment.systemPackages = [ cfg.identityBrokerPackage pkgs.intune-portal ];
    systemd.packages = [ cfg.identityBrokerPackage ];
    systemd.services.microsoft-identity-device-broker.enable = true;
    systemd.user.services.microsoft-identity-broker.enable = true;
    # Only really want the wants file set, but haven't been able to figure out how to do what without setting the whole thing here
    systemd.user.timers.intune-agent = {
      enable = true;
      description = "Intune Agent scheduler";
      after = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      unitConfig = {
        DefaultDependencies = "no";
      };
      timerConfig = {
        AccuracySec = "2m";
        OnStartupSec = "5m";
        OnUnitActiveSec = "1h";
        RandomizedDelaySec = "10m";
      };
      wantedBy = [ "graphical-session.target" ];
    };

    services.dbus.packages = [ cfg.identityBrokerPackage ];
  };

  meta = {
    maintainers = with maintainers; [ JamieMagee ];
  };
}
