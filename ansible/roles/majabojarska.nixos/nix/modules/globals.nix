{ lib, ... }:

{
  options.globals = {
    adminEmail = lib.mkOption {
      type = lib.types.str;
      default = "majabojarska98@gmail.com";
      description = "Administrator email address";
    };

    baseDomain = lib.mkOption {
      type = lib.types.str;
      default = "majabojarska.dev";
      description = "Base domain name";
    };

    cloudDomain = lib.mkOption {
      type = lib.types.str;
      default = "cloud.majabojarska.dev";
      description = "Cloud subdomain";
    };

    homeDomain = lib.mkOption {
      type = lib.types.str;
      default = "home.majabojarska.dev";
      description = "Home subdomain";
    };

    sp6catVm01HswroDomain = lib.mkOption {
      type = lib.types.str;
      default = "sp6cat-vm-01.hswro.majabojarska.dev";
      description = "sp6cat-vm-01.hswro subdomain";
    };
  };
}
