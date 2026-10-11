{ pkgs, lib, ... }:
{

  programs.git = {
    enable = true;
    settings = {
      user.name = "Rhys Davies";
      user.email = "rhys@memes.nz";
      gpg.ssh.allowedSignersFile = "${pkgs.writeText "allowed_signers" ''
        rhys@memes.nz ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIADS/M9YD+SZToazGVMVDR1P1JVW8LY6eY+MJ8skGp+S
        rhys@memes.nz ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBCY3oqsIGMbxTT3Ehh4iVyIbrmzXzKasaUrLcfhcBwhCagQ2M6ykW9FO6K6gMP/5xYZMC0Lw/ycjN0fefhGUaNA=
      ''}";
    };

    signing = {
      format = "ssh";
      key = if pkgs.stdenv.hostPlatform.isDarwin then "~/.ssh/Idenna.pub" else "~/.ssh/id_ed25519";
      signByDefault = true;
    };
  };

  home.sessionPath = lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
    "$HOME/Library/Application Support/JetBrains/Toolbox/scripts"
  ];

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    enableVteIntegration = pkgs.stdenv.hostPlatform.isLinux;

    sessionVariables = lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
      SSH_AUTH_SOCK = "/Users/rhys/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh";
    };

    profileExtra = lib.optionalString pkgs.stdenv.hostPlatform.isDarwin ''
      eval "$(/opt/homebrew/bin/brew shellenv)"

      # OrbStack: command-line tools and integration
      source ~/.orbstack/shell/init.zsh 2>/dev/null || :
    '';
    initContent =
      let
        initExtraBeforeCompInit = lib.mkOrder 550 ''
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
      in
      lib.mkMerge [
        initExtraBeforeCompInit
        initExtra
      ];
    history = {
      share = false;
      size = 10000000000;
    };
    plugins = [
      {
        name = "zsh-nix-shell";
        file = "nix-shell.plugin.zsh";
        src = "${pkgs.zsh-nix-shell}/share/zsh-nix-shell";
      }
    ];
  };

  programs.eza.enable = true;
  programs.dircolors.enable = true;
  programs.starship.enable = true;
  programs.starship.settings = {
    add_newline = false;
    gcloud.disabled = true;
    aws.disabled = true;
  };

  home.stateVersion = "22.11";

}
