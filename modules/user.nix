{ config, ... }:
{
  users.users.${config.user} = {
    isNormalUser = true;
    hashedPassword = "$y$j9T$k9cTxhpl3769v0w3vtHHC.$RMnePBGaEHYBg3IZDSnGry3TBScXMfDpPAGXlM9EOJA";
    extraGroups = [
      "networkmanager"
      "wheel"
      "jackaudio"
      "audio"
      "video"
      "gamemode"
    ];
  };
}
