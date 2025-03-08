# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./services/matrix/matrix-authentication-service.nix
    ./services/matrix/element-web.nix
    ./services/mastodon
    ./services/matrix/maubot.nix
    ./services/samba.nix
    ./services/minio.nix
    ./services/keycloak.nix
    ./services/postgres.nix
    ./services/memesnz
    ./services/atticd.nix
    ./bcache.nix
  ];

  boot.initrd.systemd.enable = true;

  services.netdata.enable = true;

  #services.resolved.enable = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "memesnz1"; # Define your hostname.

  # Set your time zone.
  time.timeZone = "Pacific/Auckland";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp0s31f6.useDHCP = true;

  networking.useNetworkd = true;

  system.autoUpgrade.enable = false;
  system.autoUpgrade.flags = [ "--recreate-lock-file" ];
  system.autoUpgrade.allowReboot = true;
  system.autoUpgrade.flake = "/etc/nixos#memesnz1";

  services.restic.backups.backup = {
    initialize = true;
    passwordFile = "/etc/restic/password";
    environmentFile = "/etc/restic/b2-creds";
    paths = [ "/var/backup" ];
    repository = "b2:memesnz-backup";
    timerConfig = {
      OnUnitActiveSec = "1d";
      OnCalendar = "daily";
    };

    pruneOpts = [
      "--keep-daily 7"
    ];
  };

  virtualisation.docker.storageDriver = "overlay2";

  security.acme.defaults.email = "letsencrypt@memes.nz";
  security.acme.acceptTerms = true;
  security.acme.certs."unifi.memes.nz" = {
    domain = "unifi.memes.nz";
    dnsProvider = "gcloud";
    credentialsFile = "/etc/gcloud/dns_creds";
    dnsPropagationCheck = true;
  };

  services.unifi.enable = true;
  services.unifi.unifiPackage = pkgs.unifi8;
  services.unifi.openFirewall = false;
  services.unifi.mongodbPackage = pkgs.mongodb-7_0;

  users.users.nginx.extraGroups = [ "mastodon" ];

  services.elasticsearch.enable = true;
  services.elasticsearch.package = pkgs.elasticsearch7;

  services.nginx = {
    enable = true;
    enableReload = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;

    additionalModules = [ pkgs.nginxModules.njs ];

    resolver.addresses = [ "127.0.0.53" ];

    commonHttpConfig = ''
      js_import http from ${./services/mastodon/http.js};
      js_fetch_trusted_certificate /etc/ssl/certs/ca-certificates.crt;

      proxy_cache_path /tmp/nginx_mstdn_media levels=1:2 keys_zone=mastodon_media:100m max_size=1g inactive=24h;
    '';

    virtualHosts = {
      "unifi.memes.nz" = {
        enableACME = true;
        acmeRoot = null;
        forceSSL = true;
        listenAddresses = [ "100.99.68.10" ];

        locations."/" = {
          proxyPass = "https://127.0.0.1:8443";
          proxyWebsockets = true;
        };
      };
      "johnguant.com" = {
        enableACME = true;
        forceSSL = true;
        globalRedirect = "memes.nz";
      };
    };

  };

  programs.nix-index.enable = true;
  programs.command-not-found.enable = false;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.rhys = {
    uid = 1000;
    isNormalUser = true;
    home = "/home/rhys";
    description = "Rhys Davies";
    extraGroups = [
      "wheel"
      "lxd"
    ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = [
      "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBCY3oqsIGMbxTT3Ehh4iVyIbrmzXzKasaUrLcfhcBwhCagQ2M6ykW9FO6K6gMP/5xYZMC0Lw/ycjN0fefhGUaNA= Idenna@secretive.Idenna.local"
      "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBP3Wq1iElJ+tcr7SOEIQaTYrF09Ci6bAFnI4MJ88Kxz9ELo8EoO9kxjzqtppKaALPKX6DJGOeA8NxuOma0dmDCE= rhys@iphone"
    ];
  };

  users.users.jamie = {
    isNormalUser = true;
    home = "/home/jamie";
    extraGroups = [
      "wheel"
      "lxd"
    ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDhVQD2IiQhzxFdJH2yF4ig3Zu3xMsisHxb2RKM3O3FaPt6hVEvgBoGSP8MuuD1Ay9t20eKZ0CFKP+v764l+AKTiMRVDiYlDO8gPoq7JQ+y6j005bry9ScPOxDs5i30opaaOYGtnbnQqgMu2QUAWgrUlMWH2jFAU9xO3yQaU4DSQK7heIP9uwvDzpQFTLy2aAma0z90fLIxg55q60ucnfwigFYGIyoFGBYnLRntCJuJ1n5qhV7Qj6dG/5rVHUrGI0cZg7vM3+kkJ8er7p9QQ3Hh9oPTwM8ueuks7k5CdKJwMy73/uJ3H3RDqVh3k73MIzcsq5x/yycFtRHbGZxmQsKTaZln8ariEY85/14jXKFYxytpgs0PKGlP/kQpCMPCArkNEL5G6WEZ+e8I4Q9huzD3uJ9lDqDLGSNJ24Ml9I0H/MF/BpPsMkFzohLyOPXu0rqbOIJX3UKTqnzDVayQ9fhEIWlgAvxZeyg6oB/XqJswbzHJHfURg9D9qX0SMve9k03HKLycB2rqpbCRajpII+C9JcN03I16/YV7iDNrjv9C72RkXc7kfuYCY2J38jdqnxMz5u5x4Vq/jp6cBjPFQC3cep5zsdRYOmwA8IwZAYPfg7+3qSgatLMouMcXxIGKrLMZvKaN1nwpjxWrcLqvS2p/MQqi42gRDNuEXa27MstxHw=="
    ];
  };

  users.users.sharlot = {
    isNormalUser = true;
    home = "/home/sharlot";
    extraGroups = [
      "wheel"
      "sonarr"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCQT+JUxSRm9j36WWr+fWwMiDZlr75Nwx9pkuMMmeSVfnTib7liptCtQYlwuO99baJTe0eMLTqt6p6KCiUOTILpp2nYflggXJgwOd7nWPuiJySMxRz/UXI42IV5HK0ljv4eahUDs0pY8BE80BQe/tO21dh1k7R4L0qS0jpWpPU/07z6SEIS2Bbt5FE24ryrYX1i9yUQl7ReIXPETCbq63tWWkszR+JDsDyn3Kuo00f5DbjKt2VO29DxBlVb4uGAvJCCrh5pPTAsLy2uW1kqB8v0RzsXNqLyGqC5Ov7jUNYi78aHZ8ikPw1DfB4ZhE9D1Ss5POmxUJ9AsvrtQyFxUQMJ imported-openssh-key"
    ];
  };

  users.users.amber = {
    isNormalUser = true;
    home = "/home/amber";
  };

  users.groups.sftponly = { };

  # List packages installed in system profile. To search, rue:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    wget
    tailscale
    git
  ];

  services.tailscale.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "no";
    settings.PasswordAuthentication = false;
  };

  # Open ports in the firewall.
  networking.firewall.allowedUDPPorts = [
    config.services.tailscale.port
    51413
  ];

  networking.firewall.allowedTCPPorts = [
    22
    80
    443
    6443
    8000
    51413
  ];
  networking.firewall.trustedInterfaces = [ "tailscale0" ];
  networking.firewall.checkReversePath = "loose";
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  services.nginx.package = pkgs.nginxStable.overrideAttrs {
    CFLAGS = "-Wno-error=discarded-qualifiers";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

}
