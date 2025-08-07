{ config, pkgs, ... }:

{
  services.samba = {
    enable = true;
    openFirewall = true;
    package = pkgs.samba4Full.override { enableCephFS = false; };
    settings = {
      "Rhys' Time Machine" = {
        path = "/mnt/s/time-machine/rhys";
        "valid users" = "rhys";
        public = "no";
        writeable = "yes";
        "force user" = "rhys";
        "fruit:aapl" = "yes";
        "fruit:model" = "MacSamba";
        "fruit:veto_appledouble" = "no";
        "fruit:posix_rename" = "yes";
        "fruit:zero_file_id" = "yes";
        "fruit:wipe_intentionally_left_blank_rfork" = "yes";
        "fruit:delete_empty_adfiles" = "yes";
        "fruit:time machine" = "yes";
        "fruit:time machine max size" = "1T";
        "vfs objects" = "catia fruit streams_xattr";
      };
      "Amber's Time Machine" = {
        path = "/mnt/s/time-machine/amber";
        "valid users" = "amber";
        public = "no";
        writeable = "yes";
        "force user" = "amber";
        "fruit:aapl" = "yes";
        "fruit:model" = "MacSamba";
        "fruit:veto_appledouble" = "no";
        "fruit:posix_rename" = "yes";
        "fruit:zero_file_id" = "yes";
        "fruit:wipe_intentionally_left_blank_rfork" = "yes";
        "fruit:delete_empty_adfiles" = "yes";
        "fruit:time machine" = "yes";
        "fruit:time machine max size" = "1T";
        "vfs objects" = "catia fruit streams_xattr";
      };
    };
  };
  services.avahi = {
    publish.enable = true;
    publish.userServices = true;
    # ^^ Needed to allow samba to automatically register mDNS records (without the need for an `extraServiceFile`
    #nssmdns4 = true;
    # ^^ Not one hundred percent sure if this is needed- if it aint broke, don't fix it
    enable = true;
    openFirewall = true;
  };
}
