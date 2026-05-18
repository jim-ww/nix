{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting
    '';
    shellInit = ''
      function fish_prompt
              set -l last_status $status
              set -l status_color
              if test $last_status -eq 0
                  set status_color (set_color --bold green)
              else
                  set status_color (set_color --bold red)
              end
              echo -n $status_color"ジ"(set_color normal)" "
              echo -n (set_color --bold cyan)(basename (prompt_pwd))(set_color normal)" "
          end

      eval (dircolors -c)
    '';
    functions.__fish_command_not_found_handler = {
      body = "__fish_default_command_not_found_handler \$argv[1]";
      onEvent = "fish_command_not_found";
    };
    functions.fish_user_key_bindings = ''
      fish_default_key_bindings -M insert
      fish_vi_key_bindings --no-erase insert
    '';
  };
}
