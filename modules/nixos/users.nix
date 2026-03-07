{ ... }:
{
  users.users.phil = {
    isNormalUser = true;
    description = "phil";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };
}
