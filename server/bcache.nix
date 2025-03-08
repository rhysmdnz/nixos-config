{ pkgs, lib, ... }:
let
  mkBcacheFs = path: devs: opts: rec {
    description = path;
    bindsTo = (
      builtins.map
        (d: "${lib.strings.removePrefix "-" (builtins.replaceStrings [ "/" ] [ "-" ] d)}.device")
        devs
    );
    after = bindsTo ++ [ "local-fs-pre.target" ];
    before = [
      "umount.target"
      "local-fs.target"
    ];
    wantedBy = [ "local-fs.target" ];
    conflicts = [ "umount.target" ];
    unitConfig = {
      RequiresMountsFor = lib.strings.concatStringsSep "/" (
        lib.lists.init (lib.strings.splitString "/" path)
      );
      DefaultDependencies = false;
    };

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.util-linux.bin}/bin/mount -o ${opts} -t bcachefs ${lib.strings.concatStringsSep ":" devs} ${path}";
      ExecStop = "${pkgs.util-linux.bin}/bin/umount ${path}";
    };
  };
in
{
  systemd.services.mnt-s =
    mkBcacheFs "/mnt/s"
      [
        "/dev/mapper/s1"
        "/dev/mapper/s2"
        "/dev/mapper/s3"
        "/dev/mapper/s4"
      ]
      "noatime,nodev,nosuid,noexec";
}
