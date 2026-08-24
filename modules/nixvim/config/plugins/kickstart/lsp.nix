{
  pkgs,
  lib,
  ...
}: {
  # Useful status updates for LSP.
  # https://nix-community.github.io/nixvim/plugins/fidget/index.html
  plugins.fidget = {
    enable = true;
    settings = {
      notification.window.winblend = 0; # transparent background
    };
  };

  # https://nix-community.github.io/nixvim/NeovimOptions/autoGroups/index.html
  autoGroups = {
    "kickstart-lsp-attach" = {
      clear = true;
    };
    "gopls-organize-imports" = {
      clear = true;
    };
  };

  # gopls can organize imports itself (source.organizeImports), so we don't
  # need a separate goimports/gotools dependency just for conform.
  autoCmd = [
    {
      event = "BufWritePre";
      group = "gopls-organize-imports";
      pattern = "*.go";
      callback.__raw = ''
        function()
          local params = vim.lsp.util.make_range_params(0, "utf-8")
          params.context = { only = { "source.organizeImports" } }
          local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 3000)
          for _, res in pairs(result or {}) do
            for _, r in pairs(res.result or {}) do
              if r.edit then
                vim.lsp.util.apply_workspace_edit(r.edit, "utf-8")
              elseif r.command then
                vim.lsp.buf.execute_command(r.command)
              end
            end
          end
        end
      '';
      desc = "Organize Go imports via gopls before save";
    }
  ];

  # jdtls needs an explicit JDK 17 to compile against (NixOS JDKs live in
  # /nix/store, not the FHS paths jdtls auto-detects) and Gradle needs to be
  # told to run its daemon on that same JDK, or it tries (and fails) to
  # download a toolchain matching the project's declared Java version.
  # extraPackages = [ pkgs.jdk17 ];

  # A plugin that properly configures LuaLS for editing your Neovim config
  #  by lazily updating your workspace libraries.
  #  https://nix-community.github.io/nixvim/plugins/lazydev/index.html
  plugins.lazydev = {
    enable = true; # autoEnableSources not enough
    settings = {
      library = [
        {
          path = "\${3rd}/luv/library";
          words = [ "vim%.uv" ];
        }
      ];
    };
  };

  # Brief aside: **What is LSP?**
  #
  # LSP is an initialism you've probably heard, but might not understand what it is.
  #
  # LSP stands for Language Server Protocol. It's a protocol that helps editors
  # and language tooling communicate in a standardized fashion.
  #
  # In general, you have a "server" which is some tool built to understand a particular
  # language (such as `gopls`, `lua_ls`, `rust_analyzer`, etc.). These Language Servers
  # (sometimes called LSP servers, but that's kind of like ATM Machine) are standalone
  # processes that communicate with some "client" - in this case, Neovim!
  #
  # LSP provides Neovim with features like:
  #  - Go to definition
  #  - Find references
  #  - Autocompletion
  #  - Symbol Search
  #  - and more!
  #
  # Thus, Language Servers are external tools that must be installed separately from
  # Neovim which are configured below in the `server` section.
  #
  # If you're wondering about lsp vs treesitter, you can check out the wonderfully
  # and elegantly composed help section, `:help lsp-vs-treesitter`
  #
  # https://nix-community.github.io/nixvim/plugins/lsp/index.html
  lsp = {
    # Enable the following language servers
    #  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
    #
    #  Add any additional override configuration in the following tables. Available keys are:
    #  - cmd: Override the default command used to start the server
    #  - filetypes: Override the default list of associated filetypes for the server
    #  - capabilities: Override fields in capabilities. Can be used to disable certain LSP features.
    #  - settings: Override the default settings passed when initializing the server.
    #        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
    servers = {
      # clangd.enable = true;
      gopls.enable = true;
      # pyright.enable = true; # alt: pylsp
      jsonls.enable = true;
      html.enable = true;
      cssls.enable = true;
      sqls.enable = true;
      templ.enable = true;
      #htmx.enable = true;
      tailwindcss.enable = true;

      docker_compose_language_service.enable = true;
      dockerls.enable = true;
      eslint.enable = true;
      # emmet_ls.enable = true;

      # ...etc. See `https://nix-community.github.io/nixvim/plugins/lsp` for a list of pre-configured LSPs
      #
      # Some languages (like typscript) have entire language plugins that can be useful:
      #    `https://nix-community.github.io/nixvim/plugins/typescript-tools/index.html?highlight=typescript-tools#pluginstypescript-toolspackage`
      #
      # But for many setups the LSP (`ts_ls`) will work just fine
      ts_ls.enable = true;

      # Nix lsp
      nil_ls.enable = true;

      # Java lsp
      # jdtls = {
      #   enable = true;
      #   settings = {
      #     java.configuration.runtimes = [
      #       {
      #         name = "JavaSE-17";
      #         path = "${pkgs.jdk17.home}";
      #         default = true;
      #       }
      #     ];
      #     # Run the Gradle daemon on the same JDK, so its declared
      #     # languageVersion=17 toolchain is satisfied without a download.
      #     java.import.gradle.java.home = "${pkgs.jdk17.home}";
      #   };
      # };

      # Lua lsp
      lua_ls = {
        enable = true;

        # cmd = {
        # };
        # filetypes = {
        # };
        config = {
          completion = {
            callSnippet = "Replace";
          };
          # diagnostics = {
          #   disable = [
          #     "missing-fields"
          #   ];
          # };
        };
      };

      svelte = {
        enable = true;
        # rootMarkers = ["svelte.config.js" "package.json" ".git"];
      };
    };

    keymaps = [
      # Diagnostic keymaps
      {
        mode = "n";
        key = "<leader>q";
        action = lib.nixvim.mkRaw "vim.diagnostic.setloclist";
        options.desc = "Open diagnostic [Q]uickfix list";
      }

      # Find references for the word under your cursor.
      {
        mode = "n";
        key = "grr";
        action.__raw = "require('telescope.builtin').lsp_references";
        options.desc = "LSP: [G]oto [R]eferences";
      }
      # Jump to the implementation of the word under your cursor.
      #  Useful when your language has ways of declaring types without an actual implementation.
      {
        mode = "n";
        key = "gri";
        action.__raw = "require('telescope.builtin').lsp_implementations";
        options.desc = "LSP: [G]oto [I]mplementation";
      }
      # Jump to the definition of the word under your cursor.
      #  This is where a variable was first declared, or where a function is defined, etc.
      #  To jump back, press <C-t>.
      {
        mode = "n";
        key = "grd";
        action.__raw = "require('telescope.builtin').lsp_definitions";
        options.desc = "LSP: [G]oto [D]efinition";
      }
      # Fuzzy find all the symbols in your current document.
      #  Symbols are things like variables, functions, types, etc.
      {
        mode = "n";
        key = "gO";
        action.__raw = "require('telescope.builtin').lsp_document_symbols";
        options.desc = "LSP: Open Document Symbols";
      }
      # Fuzzy find all the symbols in your current workspace.
      #  Similar to document symbols, except searches over your entire project.
      {
        mode = "n";
        key = "gW";
        action.__raw = "require('telescope.builtin').lsp_dynamic_workspace_symbols";
        options.desc = "LSP: Open Workspace Symbols";
      }
      # Jump to the type of the word under your cursor.
      #  Useful when you're not sure what type a variable is and you want to see
      #  the definition of its *type*, not where it was *defined*.
      {
        mode = "n";
        key = "grt";
        action.__raw = "require('telescope.builtin').lsp_type_definitions";
        options.desc = "LSP: [G]oto [T]ype Definition";
      }

      # Rename the variable under your cursor.
      #  Most Language Servers support renaming across files, etc.
      {
        key = "grn";
        lspBufAction = "rename";
        options.desc = "LSP: [R]e[n]ame";
      }
      # Execute a code action, usually your cursor needs to be on top of an error
      # or a suggestion from your LSP for this to activate.
      {
        mode = [
          "n"
          "x"
        ];
        key = "gra";
        lspBufAction = "code_action";
        options.desc = "LSP: [G]oto Code [A]ction";
      }
      # WARN: This is not Goto Definition, this is Goto Declaration.
      #  For example, in C this would take you to the header.
      {
        key = "grD";
        lspBufAction = "declaration";
        options.desc = "LSP: [G]oto [D]eclaration";
      }
    ];

    # LSP servers and clients are able to communicate to each other what features they support.
    #  By default, Neovim doesn't support everything that is in the LSP specification.
    # NOTE: This is done automatically by Nixvim when enabling blink.cmp
    #  Below is an example if you did want to add new capabilities
    #capabilities = ''
    #  require('blink.cmp').get_lsp_capabilities()
    #'';

    # This function gets run when an LSP attaches to a particular buffer.
    #   That is to say, every time a new file is opened that is associated with
    #   an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
    #   function will be executed to configure the current buffer
    # NOTE: This is an example of an attribute that takes raw lua
    onAttach = ''
      -- NOTE: Remember that Lua is a real programming language, and as such it is possible
      -- to define small helper and utility functions so you don't have to repeat yourself.
      --
      -- In this case, we create a function that lets us more easily define mappings specific
      -- for LSP related items. It sets the mode, buffer and description for us each time.
      local map = function(keys, func, desc)
        vim.keymap.set('n', keys, func, { buffer = bufnr, desc = 'LSP: ' .. desc })
      end

      -- This function resolves a difference between neovim nightly (version 0.11) and stable (version 0.10)
      ---@param client vim.lsp.Client
      ---@param method vim.lsp.protocol.Method
      ---@param bufnr? integer some lsp support methods only in specific files
      ---@return boolean
      local function client_supports_method(client, method, bufnr)
        if vim.fn.has 'nvim-0.11' == 1 then
          return client:supports_method(method, bufnr)
        else
          return client.supports_method(method, { bufnr = bufnr })
        end
      end

      -- The following two autocommands are used to highlight references of the
      -- word under your cursor when your cursor rests there for a little while.
      --    See `:help CursorHold` for information about when this is executed
      --
      -- When you move your cursor, the highlights will be cleared (the second autocommand).
      local client = vim.lsp.get_client_by_id(event.data.client_id)
      if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
        local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
        vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
          buffer = event.buf,
          group = highlight_augroup,
          callback = vim.lsp.buf.document_highlight,
        })

        vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
          buffer = event.buf,
          group = highlight_augroup,
          callback = vim.lsp.buf.clear_references,
        })

        vim.api.nvim_create_autocmd('LspDetach', {
          group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
          callback = function(event2)
            vim.lsp.buf.clear_references()
            vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
          end,
        })
      end

      -- The following code creates a keymap to toggle inlay hints in your
      -- code, if the language server you are using supports them
      --
      -- This may be unwanted, since they displace some of your code
      if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
        map('<leader>th', function()
          vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
        end, '[T]oggle Inlay [H]ints')
      end
    '';
  };
}
