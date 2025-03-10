{ config, pkgs, ... }:

{
  # services.maubot.enable = true;
  services.maubot.settings.homeservers."memes.nz".url = "https://matrix.memes.nz";
  services.maubot.plugins = with config.services.maubot.package.plugins; [ echo ];
}
