{ pkgs, lib, ... }:
{

#  programs.doom-emacs = {
#    enable = pkgs.stdenv.isLinux && pkgs.stdenv.cc.isGNU;
#    doomPrivateDir = ./doom.d;
#    emacsPackage = pkgs.emacsPgtk;
#  };

  programs.git = {
    enable = true;
    userName = "Rhys Davies";
    userEmail = "rhys@memes.nz";
    extraConfig.gpg.format = "ssh";
    signing.key = "~/.ssh/id_ed25519";
    signing.signByDefault = true;
    extraConfig.gpg.ssh.allowedSignersFile = "${pkgs.writeText ''"allowed_signers''
    ''
    rhys@memes.nz ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIADS/M9YD+SZToazGVMVDR1P1JVW8LY6eY+MJ8skGp+S
    ''}";
  };

  programs.zsh.sessionVariables = {
    SSH_AUTH_SOCK = lib.optionalString pkgs.stdenv.isDarwin "/Users/rhys/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh";
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    enableVteIntegration = pkgs.stdenv.isLinux;
    initExtraBeforeCompInit = ''
      zstyle ':completion:*' menu select
      zstyle ':completion:*' list-colors "\$\{(s.:.)LS_COLORS}"
    '';
    initExtra = ''
      setopt INC_APPEND_HISTORY
      function set_win_title(){
        echo -ne "\033]0; ''${PWD/''$HOME/~}\007"
      }
      precmd_functions+=(set_win_title)
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

  programs.eza.enable = true;
  programs.starship.enable = true;
  programs.starship.settings = {
    add_newline = false;
    gcloud.disabled = true;
    aws.disabled = true;
  };
  programs.dircolors.enable = true;

  home.stateVersion = "22.05";

}
