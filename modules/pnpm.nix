{ config, ... }:
{
  xdg.configFile."pnpm/config.yaml".text = ''
    storeDir: ${config.xdg.dataHome}/pnpm/store
    packageImportMethod: hardlink
  '';

  home.sessionVariables = {
    PNPM_HOME = "${config.xdg.dataHome}/pnpm";
  };
}
