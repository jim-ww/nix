let
  padding = val: {
    type = "padding";
    inherit val;
  };
in
{
  plugins.alpha = {
    enable = true;
    autoLoad = true;
    settings.layout = [
      (padding 4)
      {
        type = "text";
        val = [
          "⣿⣿⣿⣿⣿⣷⣿⣿⣿⡅⡹⢿⠆⠙⠋⠉⠻⠿⣿⣿⣿⣿⣿⣿⣮⠻⣦⡙⢷⡑⠘⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣌⠡⠌⠂⣙⠻⣛⠻⠷⠐⠈⠛⢱⣮⣷⣽⣿"
          "⣿⣿⣿⣿⡇⢿⢹⣿⣶⠐⠁⠀⣀⣠⣤⠄⠀⠀⠈⠙⠻⣿⣿⣿⣦⣵⣌⠻⣷⢝⠦⠚⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢟⣻⣿⣊⡃⠀⣙⠿⣿⣿⣿⣎⢮⡀⢮⣽⣿⣿"
          "⢿⣿⣿⣿⣧⡸⡎⡛⡩⠖⠀⣴⣿⣿⣿⠀⠀⠀⠀⠸⠇⠀⠙⢿⣿⣿⣿⣷⣌⢷⣑⢷⣄⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⣫⠶⠛⠉⠀⠁⠀⠈⠈⠀⠠⠜⠻⣿⣆⢿⣼⣿⣿⣿"
          "⢐⣿⣿⣿⣿⣧⢧⣧⢻⣦⢀⣹⣿⣿⣿⣇⠀⠄⠀⠀⠀⡀⠀⠈⢻⣿⣿⣿⣿⣷⣝⢦⡹⠷⡙⢿⣿⣿⣿⣿⣿⣿⣿⣿⠈⠁⠀⠀⠀⠁⠀⠀⠀⠱⣶⣄⡀⠀⠈⠛⠜⣿⣿⣿⣿"
          " ⠊⢫⣿⣏⣿⡌⣼⣄⢫⡌⣿⣿⣿⣿⣿⣦⡈⠲⣄⣤⣤⡡⢀⣠⣿⣿⣿⣿⣿⣿⣷⣼⣍⢬⣦⡙⣿⣿⣿⣿⣿⣯⢁⡄⠀⡀⡀⠀⠄⢈⣠⢪⠀⣿⣿⣿⣦⠀⢉⢂⠹⡿⣿⣿"
          "  ⠄⢹⢃⢻⣟⠙⣿⣦⠱⢻⣿⣿⣿⣿⣿⣿⣷⣬⣍⣭⣥⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⡙⢿⣼⡿⣿⣿⣿⣿⣿⣷⣄⠘⣱⢦⣤⡴⡿⢈⣼⣿⣿⣿⣇⣴⣶⣮⣅⢻⣿⡏"
          "  ⠈⠹⣇⢡⢿⡆⠻⣿⣷⠀⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣍⡻⣿⣟⣻⣿⣿⣿⣿⣷⣦⣥⣬⣤⣴⣾⣿⣿⣿⣿⣷⣿⣿⣿⣿⣷⡜⠃"
          "   ⢀⣘⠈⢂⠃⣧⡹⣿⣷⡄⠙⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣮⣅⡙⢿⣟⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠋⡕⠂"
          "      ⠛⢷⣜⢷⡌⠻⣿⣿⣦⣝⣻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣯⣹⣷⣦⣹⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠉⠃⠀ "
        ];
        opts = {
          hl = "Type";
          position = "center";
        };
      }
      (padding 3)
      {
        type = "text";
        val = [ "╭────────────────────────────────────╮" ];
        opts.position = "center";
      }
      (padding 1)
      {
        type = "group";
        val = [
          {
            type = "button";
            val = "  Find File";
            on_press.__raw = "function() require('telescope.builtin').find_files() end";
            opts = {
              shortcut = "f";
              position = "center";
              align_shortcut = "right";
              hl_shortcut = "Keyword";
              width = 44;
              cursor = 3;
              keymap = [
                "n"
                "f"
                "<cmd>Telescope find_files<CR>"
                {
                  noremap = true;
                  silent = true;
                  nowait = true;
                }
              ];
            };
          }
          {
            type = "button";
            val = "  Projects"; # Recent
            # on_press.__raw = "function() require('telescope').extensions.projects.projects() end";
            on_press.__raw = ''
              function()
                require("telescope.builtin").find_files({
                  prompt_title = "Projects in ~/Projects",
                  cwd = "~/Projects",
                  find_command = { "fd", "--type", "d", "--max-depth", "1" },
                })
              end
            '';
            opts = {
              shortcut = "p";
              position = "center";
              align_shortcut = "right";
              hl_shortcut = "Keyword";
              width = 44;
              cursor = 3;
              keymap = [
                "n"
                "p"
                # "<cmd>Telescope projects<CR>"
                ''<cmd>lua require('telescope.builtin').find_files({cwd = '~/Projects', prompt_title = 'Projects in ~/Projects',find_command = { "fd", "--type", "d", "--max-depth", "1" }})<CR>''
                {
                  noremap = true;
                  silent = true;
                  nowait = true;
                }
              ];
            };
          }
          {
            type = "button";
            val = "  Recent Files";
            on_press.__raw = "function() require('telescope.builtin').oldfiles() end";
            opts = {
              shortcut = "r";
              position = "center";
              align_shortcut = "right";
              hl_shortcut = "Keyword";
              width = 44;
              cursor = 3;
              keymap = [
                "n"
                "r"
                "<cmd>Telescope oldfiles<CR>"
                {
                  noremap = true;
                  silent = true;
                  nowait = true;
                }
              ];
            };
          }
          {
            type = "button";
            val = "󰂺  LeetCode"; #  󰢻 󰂺 
            on_press.__raw = "function() vim.cmd('Leet') end";
            opts = {
              shortcut = "l";
              position = "center";
              align_shortcut = "right";
              hl_shortcut = "Keyword";
              width = 44;
              cursor = 3;
              keymap = [
                "n"
                "l"
                "<cmd>Leet<CR>"
                {
                  noremap = true;
                  silent = true;
                  nowait = true;
                }
              ];
            };
          }
          {
            type = "button";
            val = "  New File";
            on_press.__raw = "function() vim.cmd[[enew]] end";
            opts = {
              shortcut = "e";
              position = "center";
              align_shortcut = "right";
              hl_shortcut = "Keyword";
              width = 44;
              cursor = 3;
              keymap = [
                "n"
                "e"
                "<cmd>enew<CR>"
                {
                  noremap = true;
                  silent = true;
                  nowait = true;
                }
              ];
            };
          }
          {
            type = "button";
            val = "󰅙  Quit Neovim";
            on_press.__raw = "function() vim.cmd[[qa]] end";
            opts = {
              shortcut = "q";
              position = "center";
              align_shortcut = "right";
              hl_shortcut = "Keyword";
              width = 44;
              cursor = 3;
              keymap = [
                "n"
                "q"
                "<cmd>qa<CR>"
                {
                  noremap = true;
                  silent = true;
                  nowait = true;
                }
              ];
            };
          }
        ];
        opts.spacing = 1;
      }
      (padding 1)
      {
        type = "text";
        val = [ "╰────────────────────────────────────╯" ];
        opts.position = "center";
      }
      (padding 3)
      {
        type = "text";
        val = "Weeks of coding can save you hours of planning";
        opts = {
          hl = "Keyword";
          position = "center";
        };
      }
    ];
  };
}
