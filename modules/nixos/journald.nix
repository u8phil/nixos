{ ... }:

{
  services.journald.settings.Journal = {
    SystemMaxUse = "32M";
    RuntimeMaxUse = "32M";
  };
}
