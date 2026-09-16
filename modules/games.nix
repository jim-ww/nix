{ pkgs, ... }:
{
  hardware.graphics.enable32Bit = true;

  environment.variables.PROTONPATH = pkgs.proton-ge-bin.steamcompattool;

  environment.systemPackages = [
    pkgs.umu-launcher
  ];

  programs.steam = {
    enable = true;
    # protontricks.enable = true;
    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];
  };
}
