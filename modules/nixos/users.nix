{ ... }:
{
  users.mutableUsers = false;

  users.users.phil = {
    isNormalUser = true;
    description = "phil";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    hashedPassword = "$y$j9T$lyT7epQMLV/HsWKXl5Syj/$3cm43fXtQHwrdO1vpQsxk5P0JqNAWgofEbBH27s0W41";
  };

  security.sudo-rs = {
    enable = true;
    extraRules = [
      {
        users = ["phil"];
        commands = [
          {
            command = "ALL";
            options = ["NOPASSWD"];
          }
        ];
      }
    ];
  };
}
