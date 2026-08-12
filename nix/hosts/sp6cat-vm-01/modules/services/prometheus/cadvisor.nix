{ config, ... }:
{
  services.cadvisor = {
    enable = true;
    listenAddress = "0.0.0.0";
    port = config.hosts.sp6catVm01.ports.cadvisor;
  };
}
