{
  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;
    # distrobox will not work in rootless
    #rootless = {
    #  enable = true;
    #  setSocketVariable = true;
    #};
  };
  # for docker cross compile builds
  #boot.binfmt.emulatedSystems = ["aarch64-linux"];
}
