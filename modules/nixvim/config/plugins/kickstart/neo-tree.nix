{
  # Neo-tree is a Neovim plugin to browse the file system
  # https://nix-community.github.io/nixvim/plugins/neo-tree/index.html?highlight=neo-tree#pluginsneo-treepackage
  plugins.neo-tree = {
    enable = true;

    popup_border_style = "rounded";

    settings = {
      window = {
        width = 40;
      };
      filesystem = {
        filtered_items = {
          visible = false;
          hide_dotfiles = true;
          hide_gitignored = true;
          hide_by_name = [
            ".terraform"
            "node_modules"
          ];
          hide_by_pattern = [
            "*.tfstate"
            "*.tfstate.backup"
            # "crash.log"
          ];
          # never_show = [
          #   ".terraform"
          # ];
          # never_show_by_pattern = [
          #   "*.tfstate*"
          # ];
        };
      };
    };
    /*
      filesystem = {
        window = {
          mappings = {
            "\\" = "close_window";
          };
        };
      };
    */
  };

  # https://nix-community.github.io/nixvim/keymaps/index.html
  keymaps = [
    {
      key = "\\";
      action = "<cmd>Neotree reveal<cr>";
      options = {
        desc = "NeoTree reveal";
      };
    }
  ];
}
