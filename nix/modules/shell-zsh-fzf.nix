{ pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      l = "ls -CF";
      la = "ls -A";
      ll = "ls -lah";
      lj = "lazyjournal";
      ldok = "lazydocker";
      st = "systemctl-tui";
    };
    interactiveShellInit = ''
      bindkey -e

      HISTFILE=~/.zsh_history
      HISTSIZE=10000
      SAVEHIST=10000
      setopt APPEND_HISTORY
      setopt SHARE_HISTORY
      setopt HIST_IGNORE_DUPS
      setopt HIST_IGNORE_SPACE
    '';
  };

  users.defaultUserShell = pkgs.zsh;
  users.users.root.shell = pkgs.zsh;

  system.activationScripts.zshDefaultUserRc.text = ''
    while IFS=: read -r user _ uid gid _ home shell; do
      case "$shell" in
        */zsh) ;;
        *) continue ;;
      esac

      if [ -d "$home" ] && [ -w "$home" ] && [ ! -e "$home/.zshrc" ]; then
        cat > "$home/.zshrc" <<'EOF'
# Managed by NixOS activation to skip zsh-newuser-install.
# Shared shell defaults are configured centrally via programs.zsh.
EOF
        chown "$uid:$gid" "$home/.zshrc"
        chmod 0644 "$home/.zshrc"
      fi
    done < /etc/passwd
  '';

  programs.fzf = {
    keybindings = true;
    fuzzyCompletion = true;
  };
}
