{
  plugins.bufferline = {
    enable = true;

    settings = {
      options = {
        diagnostics = "nvim_lsp"; # show LSP errors/warnings on tabs
        # offset neo-tree sidebar
        offsets = [
          {
            filetype = "neo-tree";
            text = "Neo-Tree";
            highlight = "Directory";
            text_align = "left";
            separator = true;
            # padding = 1;
          }
        ];
      };
      # transparency for bufferline (does not work)
      #   highlights = {
      #     fill = {bg = "NONE";};
      #     background = {bg = "NONE";};
      #     buffer = {bg = "NONE";};
      #     buffer_visible = {bg = "NONE";};
      #     buffer_selected = {
      #       bg = "NONE";
      #       bold = true;
      #       italic = false;
      #     };
      #
      #     separator = {
      #       fg = "NONE";
      #       bg = "NONE";
      #     };
      #     separator_visible = {
      #       fg = "NONE";
      #       bg = "NONE";
      #     };
      #     separator_selected = {
      #       fg = "NONE";
      #       bg = "NONE";
      #     };
      #
      #     modified = {bg = "NONE";};
      #     modified_visible = {bg = "NONE";};
      #     modified_selected = {bg = "NONE";};
      #
      #     close_button = {bg = "NONE";};
      #     close_button_visible = {bg = "NONE";};
      #     close_button_selected = {bg = "NONE";};
      #
      #     numbers = {bg = "NONE";};
      #     numbers_visible = {bg = "NONE";};
      #     numbers_selected = {bg = "NONE";};
      #
      #     # Diagnostics & extra groups that often keep solid bg
      #     diagnostic = {bg = "NONE";};
      #     diagnostic_visible = {bg = "NONE";};
      #     diagnostic_selected = {bg = "NONE";};
      #     error = {bg = "NONE";};
      #     error_visible = {bg = "NONE";};
      #     error_selected = {bg = "NONE";};
      #     warning = {bg = "NONE";};
      #     warning_visible = {bg = "NONE";};
      #     warning_selected = {bg = "NONE";};
      #   };
    };
    # luaConfig.post =
    #   #Lua
    #   ''
    #     vim.g.transparent_groups = vim.list_extend(
    #            vim.g.transparent_groups or {},
    #            vim.tbl_map(function(v)
    #                    return v.hl_group
    #            end, vim.tbl_values(require("bufferline.config").highlights))
    #     )
    #   '';
  };

  keymaps = [
    {
      mode = "n";
      key = "<A-S-Tab>"; # "<A-h>" "<C-S-Tab>";
      action = "<cmd>BufferLineCyclePrev<cr>";
      options.desc = "Previous buffer";
    }
    {
      mode = "n";
      key = "<A-Tab>"; # "<A-l>" "<C-Tab>";
      action = "<cmd>BufferLineCycleNext<cr>";
      options.desc = "Next buffer";
    }
    {
      mode = "n";
      key = "<A-c>";
      action = "<cmd>if len(filter(getbufinfo(), 'v:val.listed')) <= 1 | enew | bd | else | bp | bd # | endif<cr>"; # # "<cmd>bp | bd #<cr>";
      options.desc = "Close current buffer (switch to previous buffer, if exists and close previous buffer)";
    }
    {
      mode = "n";
      key = "<A-1>";
      action = "<cmd>BufferLineGoToBuffer 1<cr>";
      options.desc = "Go to buffer 1";
    }
    {
      mode = "n";
      key = "<A-2>";
      action = "<cmd>BufferLineGoToBuffer 2<cr>";
      options.desc = "Go to buffer 2";
    }
    {
      mode = "n";
      key = "<A-3>";
      action = "<cmd>BufferLineGoToBuffer 3<cr>";
      options.desc = "Go to buffer 3";
    }
    {
      mode = "n";
      key = "<A-4>";
      action = "<cmd>BufferLineGoToBuffer 4<cr>";
      options.desc = "Go to buffer 4";
    }
    {
      mode = "n";
      key = "<A-5>";
      action = "<cmd>BufferLineGoToBuffer 5<cr>";
      options.desc = "Go to buffer 5";
    }
    {
      mode = "n";
      key = "<A-6>";
      action = "<cmd>BufferLineGoToBuffer 6<cr>";
      options.desc = "Go to buffer 6";
    }
    {
      mode = "n";
      key = "<A-7>";
      action = "<cmd>BufferLineGoToBuffer 7<cr>";
      options.desc = "Go to buffer 7";
    }
    {
      mode = "n";
      key = "<A-8>";
      action = "<cmd>BufferLineGoToBuffer 8<cr>";
      options.desc = "Go to buffer 8";
    }
    {
      mode = "n";
      key = "<A-9>";
      action = "<cmd>BufferLineGoToBuffer 9<cr>";
      options.desc = "Go to buffer 9";
    }
  ];

  # does not work
  # plugins.transparent.settings.extra_groups = [
  #   "BufferLineFill"
  #   "BufferLineBackground"
  #   "BufferLineBuffer"
  #   "BufferLineBufferVisible"
  #   "BufferLineBufferSelected"
  #   "BufferLineSeparator"
  #   "BufferLineSeparatorVisible"
  #   "BufferLineSeparatorSelected"
  #   "BufferLineModified"
  #   "BufferLineModifiedSelected"
  # ];
}
