{ config, pkgs, ... }:

{
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_18;
    authentication = ''
      local mas           mas_user      peer map=mas
      local "kiwicon-irc" kiwicon-irc-2 peer map=kiwicon-irc
    '';
    identMap = ''
      mas         matrix-authentication-service mas_user
      kiwicon-irc matrix-appservice-irc         kiwicon-irc-2
    '';
  };

  services.postgresqlBackup.enable = true;
  services.postgresqlBackup.compression = "zstd";
  services.postgresqlBackup.compressionLevel = 19;
  services.postgresqlBackup.location = "/mnt/s/backup/postgresql";

  environment.systemPackages = [
    (pkgs.writeScriptBin "upgrade-pg-cluster" ''
      set -eux
      # XXX it's perhaps advisable to stop all services that depend on postgresql
      systemctl stop postgresql

      export NEWDATA="${config.services.postgresql.dataDir}"
      export NEWBIN="${config.services.postgresql.package}/bin"

      export OLDDATA="/var/lib/postgresql/${pkgs.postgresql_17.psqlSchema}"
      export OLDBIN="${pkgs.postgresql_17}/bin"

      install -d -m 0700 -o postgres -g postgres "$NEWDATA"
      cd "$NEWDATA"
      sudo -u postgres $NEWBIN/initdb -D "$NEWDATA" --no-data-checksums

      sudo -u postgres $NEWBIN/pg_upgrade \
        --old-datadir "$OLDDATA" --new-datadir "$NEWDATA" \
        --old-bindir $OLDBIN --new-bindir $NEWBIN \
        "$@"
    '')
  ];
}
