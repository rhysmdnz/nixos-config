{ pkgs, ... }:
{

  home.packages = [
    pkgs.starship
  ];

  programs.doom-emacs = {
    enable = true;
    doomPrivateDir = ./doom.d;
    emacsPackage = pkgs.emacsPgtkNativeComp;
  };

  programs.git = {
    enable = true;
    userName = "Rhys Davies";
    userEmail = "rhys@memes.nz";
  };

  programs.zsh.sessionVariables = {
    NIX_PATH = "nixpkgs=${pkgs.path}";
  };

  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    enableSyntaxHighlighting = true;
    enableVteIntegration = true;
    initExtraBeforeCompInit = ''
      zstyle ':completion:*' menu select
      zstyle ':completion:*' list-colors "\$\{(s.:.)LS_COLORS}"
    '';
    initExtra = ''
      setopt INC_APPEND_HISTORY
      export NIX_PATH="nixpkgs=${pkgs.path}"
    '';
    history = {
      share = false;
      size = 10000000000;
    };
    plugins = [
      {
        name = "zsh-nix-shell";
        file = "nix-shell.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "chisui";
          repo = "zsh-nix-shell";
          rev = "v0.4.0";
          sha256 = "037wz9fqmx0ngcwl9az55fgkipb745rymznxnssr3rx9irb6apzg";
        };
      }
    ];
  };

  programs.exa.enable = true;
  programs.exa.enableAliases = true;
  programs.starship.enable = true;
  programs.starship.settings = {
    add_newline = false;
  };
  programs.dircolors.enable = true;

}
