{
  plugins.claudecode = {
    enable = true;
    settings = {
      terminal_cmd = "bwrap-cwd claude";
    };
  };
  keymaps = [
    {
      mode = "n";
      key = "<leader>ac";
      action = "<cmd>ClaudeCode<CR>";
      options.desc = "Claude: Toggle";
    }
    {
      mode = "n";
      key = "<leader>af";
      action = "<cmd>ClaudeCodeFocus<CR>";
      options.desc = "Claude: Focus";
    }
    {
      mode = "n";
      key = "<leader>ar";
      action = "<cmd>ClaudeCode --resume<CR>";
      options.desc = "Claude: Resume";
    }
    {
      mode = "n";
      key = "<leader>aC";
      action = "<cmd>ClaudeCode --continue<CR>";
      options.desc = "Claude: Continue";
    }
    {
      mode = "n";
      key = "<leader>ab";
      action = "<cmd>ClaudeCodeAdd %<CR>";
      options.desc = "Claude: Add current buffer";
    }
    {
      mode = "v";
      key = "<leader>as";
      action = "<cmd>ClaudeCodeSend<CR>";
      options.desc = "Claude: Send selection";
    }
    {
      mode = "n";
      key = "<leader>aa";
      action = "<cmd>ClaudeCodeDiffAccept<CR>";
      options.desc = "Claude: Accept diff";
    }
    {
      mode = "n";
      key = "<leader>ad";
      action = "<cmd>ClaudeCodeDiffDeny<CR>";
      options.desc = "Claude: Deny diff";
    }
  ];
}
