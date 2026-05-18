{
  # Noice needs `snacks.nvim` or `nvim-notify` for routes using the `notify` view
  plugins.notify = {
    enable = true;
    settings = {
      background_colour = "#000000"; # transpart
      timeout = 3000;
      stages = "fade_in_slide_out"; # or "slide", "static"
      top_down = false; # show at bottom instead of top
    };
  };

  plugins.noice = {
    enable = true;
    settings = {
      cmdline = {
        enabled = true;
        view = "cmdline_popup"; # 'cmdline' classic, 'cmdline_popup' floating
      };
      views.cmdline_popup.position = {
        row = "40%";
        col = "50%";
      };
      messages = {
        enabled = true;
      };
      popupmenu = {
        enabled = true;
      };
      presets = {
        bottom_search = true; # keep / and ? at bottom
        command_palette = true; # nice centered : palette
        long_message_to_split = true;
        lsp_doc_border = true; # add a border to hover docs and signature help
        # inc_rename = false; # enables an input dialog for inc-rename.nvim
      };
      lsp = {
        override = {
          "vim.lsp.util.convert_input_to_markdown_lines" = true;
          "vim.lsp.util.stylize_markdown" = true;
          # "cmp.entry.get_documentation" = true; # if using nvim-cmp
        };
      };
    };
  };
}
