{ pkgs, ... }:

{
  programs.bash = {
    enable = true;
    completion.enable = true;
    shellAliases = {
      l = "ls -CF";
      la = "ls -A";
      ll = "ls -lah";
      lj = "lazyjournal";
      ldok = "lazydocker";
      st = "systemctl-tui";
    };
    interactiveShellInit = ''
      # Emacs keybindings (bash default).
      set -o emacs

      HISTFILE=~/.bash_history
      HISTSIZE=10000
      HISTFILESIZE=10000
      HISTCONTROL=ignoreboth:erasedups
      shopt -s histappend
    '';
  };

  users.defaultUserShell = pkgs.bash;
  users.users.root.shell = pkgs.bash;

  programs.fzf = {
    keybindings = true;
    fuzzyCompletion = true;
  };
}
