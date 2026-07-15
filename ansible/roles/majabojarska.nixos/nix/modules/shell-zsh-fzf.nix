{ pkgs, ... }:

{
  programs.zsh.enable = true;

  users.defaultUserShell = pkgs.zsh;
  users.users.root.shell = pkgs.zsh;

  programs.fzf = {
    keybindings = true;
    fuzzyCompletion = true;
  };
}
