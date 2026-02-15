let
  # Developers
  x260 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBW+jmBmPtDv+Bw21i9J4p/pZPdM7SggxBF9FGOWXSM8 majabojarska98@gmail.com";
  developers = [ x260 ];

  # Systems
  vps-01 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP1Kt0nVIUd8WkwK7etXXEPEt40HX2i6GNzyPHsy8q+b";
in
{
  "ovh.age".publicKeys = [ vps-01 ] ++ developers;
  "nextcloud-admin-pass.age".publicKeys = [ vps-01 ] ++ developers;
  "fah-token.age".publicKeys = [ vps-01 ] ++ developers;
  "searx-secret-key.age".publicKeys = [ vps-01 ] ++ developers;
  "tailscale-auth-key.age".publicKeys = [ vps-01 ] ++ developers;
}
