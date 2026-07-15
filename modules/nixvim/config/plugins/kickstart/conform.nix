{pkgs, ...}: let
  # Nursery/unstable: sorts Tailwind-style classes but can't read a
  # project's tailwind.config.js, so this uses biome's hardcoded default
  # Tailwind preset only.
  biomeSortClassesConfigDir = pkgs.writeTextDir "biome.jsonc" ''
    {
      "linter": {
        "rules": {
          "nursery": {
            "useSortedClasses": "warn"
          }
        }
      }
    }
  '';
in {
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
    prettierd
    #prettier-plugin-go-template
    google-java-format
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
        java = [
          "google-java-format"
          "trim_whitespace"
          "trim_newlines"
        ];
        python = [
          "ruff_format"
          "trim_whitespace"
          "trim_newlines"
        ];
        javascript = {
          __unkeyed-1 = "biome";
          __unkeyed-2 = "biome-sort-classes";
          timeout_ms = 2000;
        };
        typescript = {
          __unkeyed-1 = "biome";
          __unkeyed-2 = "biome-sort-classes";
          timeout_ms = 2000;
        };
        javascriptreact = {
          __unkeyed-1 = "biome";
          __unkeyed-2 = "biome-sort-classes";
          timeout_ms = 2000;
        };
        typescriptreact = {
          __unkeyed-1 = "biome";
          __unkeyed-2 = "biome-sort-classes";
          timeout_ms = 2000;
        };
        svelte = {
          lsp_format = "first";
        };
        html = ["prettierd"]; # biome
        css = ["biome"];
        json = ["biome"]; # jq
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
        biome-sort-classes = {
          command = "biome";
          args = [
            "check"
            "--write"
            "--unsafe"
            "--only=nursery/useSortedClasses"
            "--config-path"
            "${biomeSortClassesConfigDir}"
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
