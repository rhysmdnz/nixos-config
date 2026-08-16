{
  lib,
  config,
  pkgs,
  ...
}:

{

  services.nginx.virtualHosts."smokeping" = {
    enableACME = true;
    forceSSL = true;
  };

  services.smokeping.enable = true;
  services.smokeping.host = "smokeping.memes.nz";
  services.smokeping.hostName = "smokeping.memes.nz";
  services.smokeping.webService = true;

  services.smokeping.probeConfig = ''
    + FPing
    binary = ${config.security.wrapperDir}/fping
    protocol = 4
    hostinterval = 15
    offset = 0%
    pings = 20
    step = 300
    timeout = 1.5

    + FPing6
    binary = ${config.security.wrapperDir}/fping
    protocol = 6
    hostinterval = 15
    offset = 0%
    pings = 20
    step = 300
    timeout = 1.5

    +DNS
    binary = ${pkgs.dig}/bin/dig
    lookup = "nixos.org"
    forks = 5
    offset = 50%
    step = 300
    timeout = 15

    + Curl
    binary = ${pkgs.curl}/bin/curl
    forks = 5
    offset = 50%
    step = 300
    urlformat = http://%host/
  '';

  services.smokeping.targetConfig = ''
    probe = FPing
    menu = Top
    title = Network Latency Grapher
    remark = Welcome to the SmokePing website of memesnz

    @include ${./targets}/dns.conf
    @include ${./targets}/alibaba.conf
    @include ${./targets}/amazonaws.conf
    @include ${./targets}/linode.conf
    @include ${./targets}/oraclecloud.conf
    @include ${./targets}/ovh.conf
    @include ${./targets}/vultr.conf
  '';
}
