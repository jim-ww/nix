{ lib, ... }:
{
  plugins.leetcode = {
    enable = true;
    settings = {
      lang = "golang";
      storage = {
        cache = lib.nixvim.mkRaw "vim.fn.stdpath('cache') .. '/leetcode'";
        home = "~/Projects/leetcode";
      };
      image_support = true;
      injector = {
        golang = {
          before = [
            "package leetcode"
            # "// % speed"
            # "// % memory"
            "//lint:ignore U1000"
          ];
          #after = [""];
        };
      };
    };
  };
}
