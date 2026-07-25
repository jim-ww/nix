{
  # Neo-tree is a Neovim plugin to browse the file system
  # https://nix-community.github.io/nixvim/plugins/neo-tree/index.html?highlight=neo-tree#pluginsneo-treepackage
  plugins.neo-tree = {
    enable = true;
    settings = {
      window = {
        width = 40;
      };
      filesystem = {
        follow_current_file = {
          enabled = true;
          leave_dirs_open = false;
        };
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
            "*_templ.go"
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
