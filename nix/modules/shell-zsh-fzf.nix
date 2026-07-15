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

  programs.fzf = {
    keybindings = true;
    fuzzyCompletion = true;
  };
}
