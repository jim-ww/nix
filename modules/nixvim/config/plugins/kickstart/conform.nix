{ pkgs, ... }:
{
  # Dependencies
  #
  # https://nix-community.github.io/nixvim/NeovimOptions/index.html#extrapackages
  extraPackages = with pkgs; [
    # Used to format Lua code
    stylua
    gofumpt
    gotools # goimports
    alejandra
    templ
    biome # or prettier
    #prettier-plugin-go-template
  ];

  # Autoformat
  # https://nix-community.github.io/nixvim/plugins/conform-nvim.html
  plugins.conform-nvim = {
    enable = true;
    settings = {
      #default_format_opts = {
      #  lsp_format = "fallback";
      #};
      notify_on_error = true; # false
      format_on_save = ''
        function(bufnr)
          -- Disable "format_on_save lsp_fallback" for lanuages that don't
          -- have a well standardized coding style. You can add additional
          -- lanuages here or re-enable it for the disabled ones.
          local disable_filetypes = { c = true, cpp = true }
          if disable_filetypes[vim.bo[bufnr].filetype] then
            return nil
          else
            return {
              timeout_ms = 500,
              -- lsp_format = "fallback",
            }
          end
        end
      '';
      formatters_by_ft = {
        "*" = [
          "trim_whitespace"
          "trim_newlines"
        ];
        # NOTE: Order matters.
        go = [
          "goimports"
          "gofumpt" # "gofmt"
          "trim_whitespace"
          "trim_newlines"
        ];
        templ = [
          "templ"
          "trim_whitespace"
          "trim_newlines"
        ];
        # TODO: json
        nix = [
          "alejandra"
          "trim_whitespace"
          "trim_newlines"
        ];
        lua = [
          "stylua"
          "trim_whitespace"
          "trim_newlines"
        ];
        javascript = {
          __unkeyed-1 = "biome";
          # __unkeyed-2 = "prettierd";
          timeout_ms = 2000;
          stop_after_first = true;
        };
        typescript = {
          __unkeyed-1 = "biome";
          # __unkeyed-2 = "prettierd";
          timeout_ms = 2000;
          stop_after_first = true;
        };
        javascriptreact = {
          __unkeyed-1 = "biome";
          # __unkeyed-2 = "prettierd";
          timeout_ms = 2000;
          stop_after_first = true;
        };
        typescriptreact = {
          __unkeyed-1 = "biome";
          # __unkeyed-2 = "prettierd";
          timeout_ms = 2000;
          stop_after_first = true;
        };
        svelte = {
          lsp_format = "first";
        };
        html = [ "biome" ];
        css = [ "biome" ];
        json = [ "biome" ]; # jq
        #sql = ["sqlfluff"];
        #terraform = [ "terraform_fmt"]; # opentofu?
        #toml = [ "taplo" ];
        # bash = [
        #   "shellcheck"
        #   "shellharden"
        #   "shfmt"
        # ];

        # markdown = [
        # injected
        # mdformat
        #"biome"
        # ];
        # Conform can also run multiple formatters sequentially
        # python = [ "isort "black" ];
        #
        # You can use 'stop_after_first' to run the first available formatter from this list
        #javascript = {
        # __unkeyed-1 = "prettierd";
        # __unkeyed-2 = "prettier";
        # stop_after_first = true;
        #};
      };

      formatters = {
        biome = {
          command = "biome";
          args = [
            "format"
            "--write"
            "--stdin-file-path"
            "$FILENAME"
          ];
          require_cwd = false;
        };
      };
    };
  };

  # https://nix-community.github.io/nixvim/keymaps/index.html
  keymaps = [
    {
      mode = "";
      key = "<leader>f";
      action.__raw = ''
        function()
          require('conform').format { async = true }
        end
      ''; # , lsp_fallback = true
      options = {
        desc = "[F]ormat buffer";
      };
    }
  ];
}
