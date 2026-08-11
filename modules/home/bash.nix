{config, ...}: {
  programs.fzf = {
    enable = true;
    enableBashIntegration = false; # ble.sh handles it
  };

  programs.bash = {
    enable = true;
    historyFile = "${config.xdg.dataHome}/bash/bash_history";

    initExtra = ''
      . "$HOME/.profile"

      # bleopt default_keymap=vi
      bleopt color_scheme=base16
      bleopt exec_elapsed_mark=
      bleopt prompt_eol_mark=
      ble-face command_builtin=fg=4

      ble-import contrib/integration/fzf-initialize
      ble-import contrib/integration/fzf-completion
      ble-import contrib/integration/fzf-key-bindings

      __custom_prompt() {
        local last_status=$?
        local color
        if [[ $last_status -eq 0 ]]; then
          color='\[\e[1;32m\]'
        else
          color='\[\e[1;31m\]'
        fi
        PS1="''${color}ジ\[\e[0m\] \[\e[1;36m\]\W\[\e[0m\] "
      }
      PROMPT_COMMAND="__custom_prompt''${PROMPT_COMMAND:+; $PROMPT_COMMAND}"

      bind 'set completion-ignore-case on'
      bind 'set show-all-if-ambiguous on'
      bind '"\e[A": history-search-backward'
      bind '"\e[B": history-search-forward'
      bind '"\C-h": backward-kill-word'
    '';
  };
}
