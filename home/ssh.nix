{ osConfig, ... }:
{
  xdg.configFile."environment.d/10-ssh-agent.conf".text = ''
    SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/ssh-agent
  '';

  services.ssh-agent.enable = true;

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    includes = [ osConfig.sops.templates.ssh-host-config.path ];
    matchBlocks."*" = {
      addKeysToAgent = "yes";
      forwardAgent = true;
    };
  };
}
