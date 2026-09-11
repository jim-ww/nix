{ pkgs, lib, ... }:
{
  programs.bash.blesh.enable = true;
  programs.bash.enableLsColors = false;
  programs.bash.interactiveShellInit = lib.mkMerge [
    (lib.mkOrder 400 ''
      if [[ $PWD == "$HOME" ]]; then __d='~'; else __d=''${PWD##*/}; fi
      printf '\e[1;32mジ\e[0m \e[1;36m%s\e[0m ' "$__d"
      unset __d
    '')
    ''
      source ${pkgs.runCommand "dircolors.bash" { } "${pkgs.coreutils}/bin/dircolors -b > $out"}
    ''
  ];

  hm = { config, pkgs, ... }: {
    systemd.user.tmpfiles.rules = [ "d ${config.xdg.dataHome}/bash 0700" ];

    programs.bash = {
      enable = true;

      initExtra = ''
        HISTFILE="${config.xdg.dataHome}/bash/bash_history"
        . "$HOME/.profile"

        # for foot interactive shell
        if [[ -z "''${BLE_VERSION-}" ]]; then
          source ${pkgs.blesh}/share/blesh/ble.sh
        fi

        shopt -s autocd

        # bleopt default_keymap=vi
        bleopt color_scheme=base16
        bleopt exec_elapsed_mark=
        bleopt exec_errexit_mark=
        bleopt prompt_eol_mark=
        ble-face command_builtin=fg=4

        ble-import -d contrib/integration/fzf-initialize
        ble-import -d contrib/integration/fzf-completion
        ble-import -d contrib/integration/fzf-key-bindings

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
        bind '"\C-h": backward-kill-word'

        function ble/widget/my-history-search-backward { ble/widget/history-search "backward:point=end:$1"; }
        function ble/widget/my-history-search-forward { ble/widget/history-search "forward:point=end:$1"; }
        ble-bind -f 'up' my-history-search-backward
        ble-bind -f 'down' my-history-search-forward

        printf '\r\e[K'
      '';
    };
  };
}
