{
  pkgs,
  config,
  ...
}:
let
src = pkgs.fetchFromGitHub {
   owner = "Silvenga";
   repo = "redlib";
   rev = "v0.36.0";
   hash = "sha256-BqK3ETdqc8w6onV75GYZqdDk7ZqDuDluazmUW94bW6E=";
 };
 redlib-silvenga = pkgs.redlib.overrideAttrs (oldAttrs: {
   version = "0.36.0";
   inherit src;
   cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
     inherit src;
     name = "redlib-0.36.0-silvenga";
     hash = "sha256-eO3c7rlFna3DuO31etJ6S4c7NmcvgvIWZ1KVkNIuUqQ=";
   };
   nativeBuildInputs =
     (oldAttrs.nativeBuildInputs or [])
     ++ (with pkgs; [
       cmake
       go
       perl
       git
       rustPlatform.bindgenHook
     ]);
   checkFlags =
     (oldAttrs.checkFlags or [])
     ++ [
       "--skip=oauth::tests::test_generic_web_backend"
       "--skip=oauth::tests::test_mobile_spoof_backend"
     ];
 });
in
{
  services.redlib = {
    enable = true;
    package = redlib-silvenga;
    address = "127.0.0.1";
    port = config.sp6catVm01.ports.redlib;
    settings = {
      REDLIB_DEFAULT_THEME = "catppuccinMocha";
      REDLIB_DEFAULT_LAYOUT = "clean";
      REDLIB_DEFAULT_WIDE = true;
      REDLIB_HOME_FROM_COLLECTIONS = "on";
    };
  };

  systemd.services.redlib.serviceConfig.Restart = "always";
}
