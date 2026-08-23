{
  pkgs,
  config,
  lib,
  ...
}:
let
  gum-confirm = ''gum confirm --unselected.background="#${config.lib.stylix.colors.base02}" --selected.background="#${config.lib.stylix.colors.base0D}" --prompt.foreground="#${config.lib.stylix.colors.base05}" '';
  gum-input = ''gum input --prompt.foreground="#${config.lib.stylix.colors.base0D}" --cursor.foreground="#${config.lib.stylix.colors.base05}" '';
  gum-choose = ''gum choose --header.foreground="#${config.lib.stylix.colors.base03}" --cursor.foreground="#${config.lib.stylix.colors.base0D}" --item.foreground="#${config.lib.stylix.colors.base05}" --selected.foreground="#${config.lib.stylix.colors.base01}" --selected.background="#${config.lib.stylix.colors.base0D}" '';
in
{
  home.packages = with pkgs; [
    trashy
    gum
    jq
    poppler-utils # pdftotext
    highlight
    chafa # sixel images
    ffmpegthumbnailer # video thumbnails
  ];

  programs.lf = {
    enable = true;

    settings = {
      ignorecase = true;
      preview = true;
      icons = true;
      tabstop = 4;
      period = 1;
      ifs = "\n";
      ratios = [
        1
        2
        2
      ];
      autoquit = false;
    };

    keybindings = {
      D = "delete $fx";
      d = "trash";
      i = "$less $f";
      gc = "cd ${config.flakeDir}";
      gd = "cd ~/Downloads";
      gb = "cd ~/.local/share/bottles/bottles/test/drive_c";
      gg = "top --";
      gG = "bottom --";
      gm = "cd /run/media/${config.user}";
      a = "create";
      w = "$" + config.shell;
      x = "cut";
      Y = "copy-file";
      E = "extract";
      C = "compress";
      # B = "bulk-rename";
      P = "set preview!";
      "<c-c>" = "quit";
      "<tab>" = "!du -sh";
      "<enter>" = "open";
      "<esc>" = ":unselect; clear";
      "." = "set hidden!";
      R = "reload && redraw";
    };

    commands = {
      copy-file = ''$wl-copy -t text/uri-list "file://$(realpath $f)"'';
      on-init = "";

      open = ''
        ''${{
          case "$(file -Lb --mime-type -- "$f")" in
            text/* | application/json | application/x-subrip | inode/x-empty)
              $EDITOR "$f"
              ;;
            *)
              xdg-open "$f" > /dev/null 2>&1 &
              ;;
          esac
        }}'';

      compress = ''
        ''${{
          [ -z "$fx" ] && exit 0
          format=$(${gum-choose} ".tar.gz" ".zip" --header="choose format:")
          [ -z "$format" ] && exit 0
          name=$(${gum-input} --placeholder="archive name:")
          [ -z "$name" ] && exit 0
          ${lib.getExe pkgs._7zz} a "$name$format" $fx
        }}'';

      extract = ''''$${gum-confirm} "extract '$fx'?" && ([[ "$fx" == *.rar ]] && ${lib.getExe pkgs.unar} "$fx" || ${lib.getExe pkgs._7zz} x "$fx") || echo'';
      trash = ''''$${gum-confirm} "trash '$fx'?"   && trash $fx'';
      delete = ''''$${gum-confirm} "delete '$fx'?"  && rm -rf $fx'';

      create = ''
        ''${{
          name=$(${gum-input} --placeholder="create:")
          [ -z "$name" ] && exit 0
          if [ "''${name: -1}" = "/" ]; then
            mkdir -p -- "$name"
          else
            case "$name" in
              */*) mkdir -p -- "''${name%/*}" ;;
            esac
            touch -- "$name"
          fi
        }}'';

      # bulk-rename = ''
      #   ''${{
      #     [ -z "$fx" ] && exit 0
      #     tmpfile=$(mktemp /tmp/lf-rename.XXXXXX)
      #     echo "$fx" | while IFS= read -r f; do
      #       basename -- "$f"
      #     done > "$tmpfile"
      #     ''${VISUAL:-''${EDITOR:-vi}} "$tmpfile"
      #     dir=$(dirname "$(echo "$fx" | head -1)")
      #     i=0
      #     echo "$fx" | while IFS= read -r src; do
      #       i=$((i + 1))
      #       newname=$(sed -n "''${i}p" "$tmpfile")
      #       [ -z "$newname" ] && continue
      #       [ "$(basename -- "$src")" = "$newname" ] && continue
      #       dst="$dir/$newname"
      #       if [ -e "$dst" ]; then
      #         ${gum-confirm} "Replace '$newname'?" && mv -f -- "$src" "$dst"
      #       else
      #         mv -- "$src" "$dst"
      #       fi
      #     done
      #     rm -f "$tmpfile"
      #     lf -remote "send $id reload"
      #   }}'';

      paste = ''
        ''${{
          lf_files="''${XDG_DATA_HOME:-$HOME/.local/share}/lf/files"
          [ -f "$lf_files" ] || exit 0
          mode=$(head -1 "$lf_files")
          files=$(tail -n +2 "$lf_files")
          [ -z "$files" ] && exit 0
          printf '%s\n' "$files" | while IFS= read -r src; do
            [ -z "$src" ] && continue
            dst="$PWD/$(basename -- "$src")"
            if [ -e "$dst" ]; then
              if ${gum-confirm} "Replace '$(basename -- "$src")'?"; then
                [ "$mode" = "move" ] && mv -f -- "$src" "$dst" || cp -rf -- "$src" "$dst"
              else
                new_name=$(${gum-input} --placeholder "Enter new name for '$(basename -- "$src")'")
                [ -z "$new_name" ] && continue
                dst="$PWD/$new_name"
                [ "$mode" = "move" ] && mv -- "$src" "$dst" || cp -r -- "$src" "$dst"
              fi
            else
              [ "$mode" = "move" ] && mv -- "$src" "$dst" || cp -r -- "$src" "$dst"
            fi
          done
          [ "$mode" = "move" ] && lf -remote "send clear"
          lf -remote "send $id reload"
        }}'';

      get-mime-type = ''%xdg-mime query filetype \"$f\"'';
    };

    previewer.source = pkgs.writeShellScript "pv.sh" ''
      #!/usr/bin/env sh

      file="$1"
      width="$2"
      height="$3"

      mime=$(file -Lb --mime-type -- "$file")

      case "$mime" in
        image/webp)
          webp_tmp=$(mktemp /tmp/lf-webp.XXXXXX.png)
          ffmpeg -i "$file" -y "$webp_tmp" 2>/dev/null \
            && chafa --clear -f sixel -s "''${width}x''${height}" \
              --animate off --polite on --scale max "$webp_tmp"
          rm -f "$webp_tmp"
          exit 0
          ;;
        image/*)
          chafa --clear -f sixel -s "''${width}x''${height}" \
            --animate off --polite on --scale max "$file"
          exit 0
          ;;
        video/*)
          thumb=$(mktemp /tmp/lf-thumb.XXXXXX.jpg)
          ffmpegthumbnailer -i "$file" -o "$thumb" -s 0 -q 5 2>/dev/null \
            && chafa --clear -f sixel -s "''${width}x''${height}" \
              --animate off --polite on --scale max "$thumb"
          rm -f "$thumb"
          exit 0
          ;;
        text/* | application/json | application/x-*)
          highlight -O ansi --force "$file" 2>/dev/null || cat "$file"
          exit 0
          ;;
      esac

      case "$file" in
        *.tar* | *.tgz | *.tbz | *.txz | *.zip | *.rar | *.7z)
          ${lib.getExe pkgs._7zz} l "$file" --password 0 2>/dev/null || echo "(could not list archive)"
          ;;
        *.pdf)
          pdftotext "$file" - 2>/dev/null || echo "(pdf text extraction failed)"
          ;;
        *)
          highlight -O ansi "$file" 2>/dev/null || cat "$file"
          ;;
      esac
    '';
  };
}
