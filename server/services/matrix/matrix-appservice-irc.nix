{ config, pkgs, ... }:
{

  services.nginx.virtualHosts."kiwicon-irc-bridge.memes.nz" = {
    enableACME = true;
    forceSSL = true;

    locations."/" = {
      proxyPass = "http://127.0.0.1:9999";
    };
    locations."/metrics" = {
      proxyPass = "http://127.0.0.1:7001";
    };
  };

  services.matrix-appservice-irc.enable = true;
  services.matrix-appservice-irc.port = 9999;
  services.matrix-appservice-irc.registrationUrl = "https://kiwicon-irc-bridge.memes.nz";
  services.matrix-appservice-irc.localpart = "irc_bot";
  services.matrix-appservice-irc.settings = {
    homeserver = {
      url = "https://matrix.memes.nz";
      domain = "memes.nz";
      enablePresence = true;
    };
    ircService = {
      mediaProxy.publicUrl = "http://localhost:11111/media";
      servers = {
        "ircs.kiwicon.org" = {
          name = "Kiwicon";
          additionalAddresses = [ ];
          networkId = "kiwicon";
          port = 6697;
          ssl = true;
          sslselfsign = false;
          sasl = false;
          allowExpiredCerts = false;
          sendConnectionMessages = true;
          quitDebounce.enabled = false;
          modePowerMap.o = 50;
          modePowerMap.v = 1;
          botConfig.enabled = false;
          privateMessages = {
            enabled = true;
            federate = true;
          };
          dynamicChannels = {
            enabled = true;
            createAlias = true;
            published = true;
            joinRule = "public";
            groupId = "+kiwicon:memes.nz";
            federate = true;
            aliasTemplate = "#irc_$SERVER_$CHANNEL";
          };
          membershipLists = {
            enabled = true;
            floodDelayMs = 10000;
            global = {
              ircToMatrix.initial = true;
              ircToMatrix.incremental = true;
              matrixToIrc.initial = true;
              matrixToIrc.incremental = true;
            };
            ignoreIdleUsersOnStartup.enabled = false;
          };
          mappings."#realhacking" = {
            roomIds = [ "!TTjzJWPUTvUrHglccF:memes.nz" ];
          };
          matrixClients = {
            userTemplate = "@irc_$NICK";
            displayName = "$NICK";
            joinAttempts = -1;
          };
          ircClients = {
            nickTemplate = "$DISPLAY";
            allowNickChanges = true;
            maxClients = 30;
            ipv6.only = false;
            idleTimeout = 0;
            realnameFormat = "mxid";
          };
        };
        "irc.oftc.net" = {
          name = "OFTC";
          additionalAddresses = [ ];
          networkId = "oftc";
          port = 6697;
          ssl = true;
          sslselfsign = false;
          sasl = false;
          allowExpiredCerts = false;
          sendConnectionMessages = true;
          quitDebounce.enabled = false;
          modePowerMap.o = 50;
          modePowerMap.v = 1;
          botConfig.enabled = false;
          privateMessages = {
            enabled = true;
            federate = false;
          };
          dynamicChannels = {
            enabled = true;
            createAlias = true;
            published = true;
            joinRule = "public";
            groupId = "+oftc:memes.nz";
            federate = false;
            aliasTemplate = "#irc_$SERVER_$CHANNEL";
          };
          membershipLists = {
            enabled = true;
            floodDelayMs = 10000;
            global = {
              ircToMatrix.initial = true;
              ircToMatrix.incremental = true;
              matrixToIrc.initial = true;
              matrixToIrc.incremental = true;
            };
            ignoreIdleUsersOnStartup.enabled = false;
          };
          matrixClients = {
            userTemplate = "@$SERVER_$NICK";
            displayName = "$NICK";
            joinAttempts = 10;
          };
          ircClients = {
            nickTemplate = "$DISPLAY";
            allowNickChanges = true;
            maxClients = 30;
            ipv6.only = false;
            idleTimeout = 0;
            realnameFormat = "mxid";
          };
        };
      };
      bridgeInfoState.enabled = true;
      bridgeInfoState.initial = true;
      logging.level = "info";
      logging.toConsole = true;
      logging.maxFiles = 5;
      debugApi.enabled = true;
      debugApi.port = 11100;
      matrixHandler.eventCacheSize = 4096;
      ircHandler.mapIrcMentionsToMatrix = "on";
      permissions."@rhys:memes.nz" = "admin";
    };
    database = {
      engine = "postgres";
    };
  };
  systemd.services.matrix-appservice-irc.serviceConfig.SystemCallFilter = pkgs.lib.mkForce "~@mount";
}
