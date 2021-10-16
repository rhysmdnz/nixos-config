{ pkgs, ... }:

{

  home.packages = [
    pkgs.starship
  ];

  programs.git = {
    enable = true;
    userName = "Rhys Davies";
    userEmail = "rhys@memes.nz";
  };

  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    enableSyntaxHighlighting = true;
    #initExtra = "eval \"$(starship init zsh)\""; 
  };

  programs.exa.enable = true;
  programs.exa.enableAliases = true;
  programs.starship.enable = true;
  programs.starship.settings = {
    add_newline = false;
  };
  programs.dircolors.enable = true;

}
