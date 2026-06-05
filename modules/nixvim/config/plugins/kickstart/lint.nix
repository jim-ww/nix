{pkgs, ...}: {
  extraPackages = with pkgs; [
    golangci-lint
    ruff # python
    eslint
    htmlhint
    go-arch-lint
    #stylelint # css
  ];

  # Linting
  # https://nix-community.github.io/nixvim/plugins/lint/index.html
  plugins.lint = {
    enable = true;

    # NOTE: Enabling these will cause errors unless these tools are installed
    lintersByFt = {
      nix = ["nix"];
      go = ["golangcilint" "go_arch_lint"];
      html = ["htmlhint"];
      #css = [ "stylelint" ];
      javascript = ["eslint"];
      javascriptreact = ["eslint"];
      typescript = ["eslint"];
      typescriptreact = ["eslint"];
      svelte = ["eslint"];
      python = ["ruff"];
      #markdown = [
      #"markdownlint"
      #"vale"
      #];
      #clojure = ["clj-kondo"];
      #dockerfile = ["hadolint"];
      #inko = ["inko"];
      #janet = ["janet"];
      #json = ["jsonlint"];
      #rst = [ "vale" ];
      #ruby = ["ruby"];
      #terraform = ["tflint"];
      #text = [ "vale" ];
    };

    customLinters = {
      # fixes 'golangci-lint exited with code: 5' error
      # https://github.com/mfussenegger/nvim-lint/issues/760
      golangcilint = {
        cmd = "golangci-lint";
        stdin = false;
        stream = "stdout";
        ignore_exitcode = false;
        parser.__raw = ''
          require('lint.linters.golangcilint').parser
        '';
        args = [
          "run"
          "--output.json.path=stdout"
          "--show-stats=false"
        ];
      };
      go_arch_lint = {
        cmd = "go-arch-lint";
        args = ["check" "--project-path" "." "--output-type" "json"];
        stdin = false;
        stream = "stdout";
        ignore_exitcode = true;
        parser.__raw = ''
          function(output, bufnr)
            if output == "" then return {} end
            local ok, decoded = pcall(vim.json.decode, output)
            if not ok or not decoded or not decoded.warnings then return {} end
            local diags = {}
            for _, w in ipairs(decoded.warnings) do
              local lnum = math.max(0, ((w.details and w.details.line) or 1) - 1)
              table.insert(diags, {
                lnum = lnum,
                col = 0,
                message = (w.details and w.details.message) or w.name or "arch violation",
                severity = vim.diagnostic.severity.WARN,
                source = "go-arch-lint",
              })
            end
            return diags
          end
        '';
      };
    };

    # Create autocommand which carries out the actual linting
    # on the specified events.
    autoCmd = {
      callback.__raw = ''
        function()
          -- Only run the linter in buffers that you can modify in order to
          -- avoid superfluous noise, notably within the handy LSP pop-ups that
          -- describe the hovered symbol using Markdown.
          if vim.opt_local.modifiable:get() then
            require('lint').try_lint()
          end
        end
      '';
      group = "lint";
      event = [
        "BufEnter"
        "BufWritePost"
        "InsertLeave"
      ];
    };
  };

  # https://nix-community.github.io/nixvim/NeovimOptions/autoGroups/index.html
  autoGroups = {
    lint = {
      clear = true;
    };
  };
}
