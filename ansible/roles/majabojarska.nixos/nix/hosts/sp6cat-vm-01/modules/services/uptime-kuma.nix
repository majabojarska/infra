{ config, ... }:

{
  services.uptime-kuma = {
    enable = true;
    settings = {
      HOST = "127.0.0.1";
      PORT = toString config.sp6catVm01.ports.uptimeKuma;
    };
  };
}
