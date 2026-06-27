{ wdUsbHddMountPath, ... }:

{
  services.borgbackup.repos = {
    baczek = {
      authorizedKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILulC22JoRPoRtU5Q36cMzwo8W3DA2l58MUu9VcQEghw wint3rmute@thinkcentre"
      ];
      path = "${wdUsbHddMountPath}/borg/baczek";
      quota = "200G";
      allowSubRepos = true;
    };

    kube-01 = {
      authorizedKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN8itVsInt/KzsOTn1BqmjuDfgR5IIPuN4nT6g1JVrVt root@kube-01"
      ];
      path = "${wdUsbHddMountPath}/borg/kube-01";
      quota = "300G";
      allowSubRepos = true;
    };
  };
}
