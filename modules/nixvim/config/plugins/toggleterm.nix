{
  plugins.toggleterm = {
    enable = true;
    settings = {
      #shell = "tmux"; # will create too many tmux sessions
      direction = "horizontal";
      open_mapping = "[[<C-`>]]";
      start_in_insert = true;
      insert_mappings = true;
      terminal_mappings = true;
      shade_terminals = false;
      #shading_factor = -30;
      float_opts = {
        border = "curved";
        height = 30;
        width = 130;
        # winblend = 30; # 0 = fully opaque, 100 = fully transparent
        # highlights = {
        #   border = "Normal";
        #   background = "Normal";
        # };
      };
    };
  };

  # extraConfigLuaPre = ''
  #   if vim.env.NVIM then
  #     vim.env.GIT_EDITOR = "nvr --remote-wait +'startinsert'"
  #     vim.env.JJ_EDITOR  = "nvr --remote-wait +'startinsert'"
  #   end
  # '';

  keymaps = [
    {
      # Escape terminal mode using ESC
      mode = "t";
      key = "<esc>";
      action = "<C-\\><C-n>";
      options.desc = "Escape terminal mode";
    }
    # New: Shift+Esc cycles between horizontal ↔ tab
    {
      mode = [
        "n"
        "t"
        "i"
      ];
      key = "<S-Esc>";
      action.__raw = ''
        function()
          local term = require("toggleterm.terminal").get(1, true)
          if term == nil or not term:is_open() then
            -- not open → open in tab
            require("toggleterm").toggle(1, nil, nil, "tab")
          else
            local current_dir = term.direction
            local next_dir = (current_dir == "horizontal") and "tab" or "horizontal"
            term:close()
            require("toggleterm").toggle(1, nil, nil, next_dir)
          end
        end
      '';
      options = {
        desc = "Toggle terminal: cycle horizontal ↔ tab";
        silent = true;
        expr = false;
      };
    }
  ];
  # Fix commit messages inside toggleterm (git, jj)
  # autoCmd = [
  #   {
  #     event = ["FileType"];
  #     pattern = ["gitcommit" "jjcommit"];
  #     command = "setlocal buftype= modifiable";
  #   }
  # ];
}
