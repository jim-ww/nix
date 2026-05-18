{
  plugins.avante = {
    enable = true;
    settings = {
      instructions_file = "avante.md";
      hints = {
        enabled = true;
      };
      mappings = {
        diff = {
          both = "cb";
          next = "]x";
          none = "c0";
          ours = "co";
          prev = "[x";
          theirs = "ct";
        };
      };
      behaviour = {
        minimize_diff = true; # hide unchanged lines
        confirmation_ui_style = "popup"; # or "inline_buttons" for quick accept/reject UI
        #auto_apply_diff_after_generation = false;
        #auto_approve_tool_permissions = false; # prompts before any tool/file ops
      };
      /*
          system_prompt = ''
          You are a code editing assistant.
          Respond ONLY with final code or very short explanation.
          Do NOT think step by step.
          Do NOT show reasoning process.
          Do NOT write "Let's think", "First", "Then", "So", planning phrases.
          Produce the answer directly.
        '';
      */
      provider = "openrouter";
      providers = {
        openrouter = {
          __inherited_from = "openai";
          endpoint = "https://openrouter.ai/api/v1";
          api_key_name = "OPENROUTER_API_KEY";
          model = "openrouter/free"; # meta-llama/llama-3.3-70b-instruct qwen/qwen3-32b
          extra_request_body = {
            max_tokens = 15134; # 4096
          };
        };
      };
    };
  };
  keymaps = [
    {
      mode = "n";
      key = "<leader>aS";
      action = "<cmd>AvanteStop<CR>";
      options.desc = "Avante: Stop generation";
    }
  ];
}
