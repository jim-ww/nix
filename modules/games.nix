{pkgs, ...}: {
  programs.gamemode.enable = true;

  programs.steam = {
    enable = true;
    protontricks.enable = true;
    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];
  };

  environment.systemPackages = with pkgs; [
    umu-launcher
    mangohud
    #(bottles.override {removeWarningPopup = true;})
  ];
}
