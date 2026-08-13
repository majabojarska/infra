{ ... }:

{
  services.borgbackup = {
    repos = {
      sp6cat-vm-01 = {
        authorizedKeys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBNo31eqosBfzGo91+3ftgHMvOpKWDE3FPY5L/aw/9X1 root@sp6cat-vm-01"
        ];
        path = "/storage/mirror/borg/sp6cat-vm-01";
        quota = "32G";
        allowSubRepos = true;
      };
    };
  };

  systemd.tmpfiles.rules = [
    "D /storage/mirror/borg/sp6cat-vm-01 0751 borg borg - -"
  ];
}
