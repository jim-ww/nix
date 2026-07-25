{pkgs, ...}: {
  # Highlight, edit, and navigate code
  # https://nix-community.github.io/nixvim/plugins/treesitter/index.html
  plugins.treesitter = {
    enable = true;

    # Installing tree-sitter grammars from Nixpkgs (recommended)
    # https://nix-community.github.io/nixvim/plugins/treesitter/index.html#installing-tree-sitter-grammars-from-nixpkgs
    # grammarPackages = pkgs.vimPlugins.nvim-treesitter.passthru.allGrammars;
    grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
      # Linux
      bash
      ssh_config
      make
      c
      # sway
      # tmux # removed

      # Nix, Nixvim
      nix
      query # treesitter queries
      vim
      vimdoc
      lua
      luadoc

      # General Development
      csv
      diff
      editorconfig
      git_config
      git_rebase
      gitattributes
      gitcommit
      gitignore
      ini
      # llvm
      markdown
      markdown_inline
      regex
      yaml
      toml
      xml
      json

      # Web Development
      html
      css
      scss
      # http
      javascript
      typescript
      tsx
      svelte
      # json5
      # php
      # php_only
      # phpdoc
      sql
      # scss
      # twig
      templ

      # Go
      go
      gomod
      gosum
      gotmpl
      gowork
      templ

      # other
      sql
      markdown
      markdown_inline
      # astro
      # nginx
      #rust
    ];

    settings = {
      # Installing tree-sitter grammars from nvim-treesitter
      # (can be combined with grammarPackages from Nixpkgs)
      # https://nix-community.github.io/nixvim/plugins/treesitter/index.html#installing-tree-sitter-grammars-from-nvim-treesitter
      ensureInstalled = [];

      highlight = {
        enable = true;

        # Some languages depend on vim's regex highlighting system for indent rules.
        additional_vim_regex_highlighting = [
          "ruby"
        ];
      };

      indent = {
        enable = true;
        disable = [
          "ruby"
        ];
      };

      # There are additional nvim-treesitter modules that you can use to interact
      # with nvim-treesitter. You should go explore a few and see what interests you:
      #
      #    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
      #    - Show your current context: https://nix-community.github.io/nixvim/plugins/treesitter-context/index.html
      #    - Treesitter + textobjects: https://nix-community.github.io/nixvim/plugins/treesitter-textobjects/index.html
    };
  };
}
