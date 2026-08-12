{ config, ... }:
{
  services.cadvisor = {
    enable = true;
    listenAddress = "0.0.0.0";
    port = config.hosts.kube01.ports.cadvisor;
  };
}
