{ ... }:

{
  services.chrony = {
    enable = true;
    extraConfig = ''
      allow all
    '';
    servers = [
      "ntp2.301-moved.de" # Wuppertal
      "ntp2.rueckgr.at" # Nuremberg
      "stratum2-3.NTP.TechFak.Uni-Bielefeld.DE" # Bielefeld
      "time.hueske-edv.de" # Falkenstein
      "ntp0.hochstaetter.de" # Munich
    ];
  };
}
