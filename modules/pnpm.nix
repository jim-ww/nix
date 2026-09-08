{ config, ... }:
{
  home-manager.users.${config.user} =
    { config, ... }:
    {
      # Node resolves modules by walking up to the nearest node_modules, so every
      # project needs its own tree. pnpm makes that cheap: the tree is symlinks
      # into a single content-addressed store, with the files hardlinked, so one
      # copy of a given package version is shared by every project on the disk.
      #
      # This only works when the store and the checkouts share a filesystem.
      # /home is tmpfs here, and ~/.local/share/pnpm is persisted (see
      # impermanence.nix) on the same disk as ~/Projects, so pinning the store
      # there keeps hardlinking available instead of silently falling back to
      # copying -- which costs the full size twice, once in the store and once
      # in each node_modules.
      xdg.configFile."pnpm/rc".text = ''
        store-dir=${config.xdg.dataHome}/pnpm/store
        package-import-method=hardlink
      '';

      home.sessionVariables = {
        PNPM_HOME = "${config.xdg.dataHome}/pnpm";
      };
    };
}
