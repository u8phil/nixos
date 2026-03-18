{ ... }:

{
  services.journald.extraConfig = ''
    SystemMaxUse=32M
    RuntimeMaxUse=32M
  '';
}
