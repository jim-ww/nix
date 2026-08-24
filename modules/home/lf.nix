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
    gum
    jq
    poppler-utils # pdftotext
    highlight
    chafa # sixel images
    ffmpegthumbnailer # video thumbnails
    fuse-archive # browse into archives without extracting
    _7zz
  ];

  programs.pistol = {
    enable = true;
    associations = [
      {
        mime = "application/pdf";
        command = "pdftotext %pistol-filename% -";
      }
      {
        mime = "image/.*";
        command = "${lib.getExe pkgs.chafa} --clear -f sixel -s %pistol-extra0%x%pistol-extra1% --animate off --polite on --scale max %pistol-filename%";
      }
      {
        mime = "video/.*";
        command = "${pkgs.writeShellScript "pistol-video" ''
          thumb=$(mktemp /tmp/lf-thumb.XXXXXX.jpg)
          ${lib.getExe pkgs.ffmpegthumbnailer} -i "$1" -o "$thumb" -s 0 -q 5 2>/dev/null \
            && ${lib.getExe pkgs.chafa} --clear -f sixel -s "$2x$3" --animate off --polite on --scale max "$thumb"
          rm -f "$thumb"
        ''} %pistol-filename% %pistol-extra0% %pistol-extra1%";
      }
    ];
  };

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
      sixel = true;
    };

    keybindings = {
      D = "delete $fx";
      d = "trash";
      i = "$less $f";
      H = "leave-archive";
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
            application/zip | application/x-zip* | application/x-tar | application/gzip | application/x-gzip | application/x-bzip2 | application/x-bzip | application/x-xz | application/x-7z-compressed | application/vnd.rar | application/x-rar-compressed | application/x-lzma | application/x-compress)
              mnt="''${XDG_RUNTIME_DIR:-/tmp}/lf-archive-mounts/$(realpath -- "$f" | md5sum | cut -d' ' -f1)"
              mkdir -p "$mnt"
              if ! mountpoint -q "$mnt"; then
                if ! fuse-archive "$f" "$mnt" 2>>"''${XDG_RUNTIME_DIR:-/tmp}/lf-archive-mount.log"; then
                  xdg-open "$f" > /dev/null 2>&1 &
                  exit 0
                fi
              fi
              echo "$PWD" > "''${XDG_RUNTIME_DIR:-/tmp}/lf-archive-origin"
              lf -remote "send $id cd \"$mnt\""
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
          case "$format" in
            .tar.gz) ${lib.getExe pkgs.gnutar} -czf "$name$format" -- $fx ;;
            .zip) ${lib.getExe pkgs._7zz} a "$name$format" -- $fx ;;
          esac
        }}'';

      leave-archive = ''
        ''${{
          origin_file="''${XDG_RUNTIME_DIR:-/tmp}/lf-archive-origin"
          case "$PWD" in
            "''${XDG_RUNTIME_DIR:-/tmp}/lf-archive-mounts"*)
              if [ -f "$origin_file" ]; then
                lf -remote "send $id cd \"$(cat "$origin_file")\""
                rm -f "$origin_file"
              else
                lf -remote "send $id updir"
              fi
              ;;
            *)
              lf -remote "send $id updir"
              ;;
          esac
        }}'';

      extract = ''''$${gum-confirm} "extract '$fx'?" && ([[ "$fx" == *.rar ]] && ${lib.getExe pkgs.unar} "$fx" || ${lib.getExe pkgs._7zz} x "$fx") || echo'';

      trash = ''
        ''${{
          [ -z "$fx" ] && exit 0
          ${gum-confirm} "trash '$fx'?" || exit 0
          trash_dir="''${XDG_DATA_HOME:-$HOME/.local/share}/Trash"
          mkdir -p "$trash_dir/files" "$trash_dir/info"
          printf '%s\n' "$fx" | while IFS= read -r f; do
            [ -z "$f" ] && continue
            orig=$(realpath -- "$f")
            name=$(basename -- "$f")
            dest="$trash_dir/files/$name"
            n=1
            while [ -e "$dest" ]; do
              dest="$trash_dir/files/$name.$n"
              n=$((n + 1))
            done
            mv -- "$f" "$dest" 2>/dev/null || { cp -a -- "$f" "$dest" && rm -rf -- "$f"; }
            {
              echo "[Trash Info]"
              echo "Path=$orig"
              echo "DeletionDate=$(date +%Y-%m-%dT%H:%M:%S)"
            } > "$trash_dir/info/$(basename -- "$dest").trashinfo"
          done
        }}'';

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

    previewer.source = lib.getExe pkgs.pistol;
  };
}
