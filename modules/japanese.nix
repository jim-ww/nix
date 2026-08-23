{ pkgs, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      qt6Packages = prev.qt6Packages // {
        fcitx5-with-addons = prev.qt6Packages.fcitx5-with-addons.override {
          withConfigtool = false;
        };
      };
    })
  ];

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.waylandFrontend = true;

    fcitx5.addons = with pkgs; [
      fcitx5-mozc
      fcitx5-gtk
    ];

    fcitx5.settings = {
      inputMethod = {
        "Groups/0" = {
          Name = "Default";
          "Default Layout" = "jp"; # "us"
          DefaultIM = "mozc";
        };
        "Groups/0/Items/0".Name = "keyboard-jp";
        "Groups/0/Items/1".Name = "mozc";
        GroupOrder."0" = "Default";
      };

      globalOptions = {
        "Hotkey/TriggerKeys"."0" = "Control+Shift+space";
      };
    };
  };
}
