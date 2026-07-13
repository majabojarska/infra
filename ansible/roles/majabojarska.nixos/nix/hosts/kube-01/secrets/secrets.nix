let
  developers = import ../../../modules/keys-developers.nix;

  # Systems
  kube-01 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBLa2Aq4Zw4RImQ+XHRHxS7gSrKtwan5bEtg6D20k5TT root@nixos";
in
{
  "tailscale-auth-key.age".publicKeys = [ kube-01 ] ++ developers;
  "borgmatic-kubernetes-enc-pass.age".publicKeys = [ kube-01 ] ++ developers;
  "telegram-bot-token.age".publicKeys = [ kube-01 ] ++ developers;
  "telegram-chat-id.age".publicKeys = [ kube-01 ] ++ developers;
}
