{
  pkgs,
  config,
  lib,
  ...
}:
let
  trash = pkgs.writeShellScriptBin "trash" ''
    set -euo pipefail
    yes=0
    if [ "''${1:-}" = "-y" ]; then
      yes=1
      shift
    fi
    [ "$#" -eq 0 ] && exit 0
    if [ "$yes" -ne 1 ]; then
      read -r -p "trash $# item(s)? [y/N] " ans
      case "$ans" in
        y | Y) ;;
        *) exit 0 ;;
      esac
    fi
    trash_dir="''${XDG_DATA_HOME:-$HOME/.local/share}/Trash"
    mkdir -p "$trash_dir/files" "$trash_dir/info"
    for f in "$@"; do
      if [ ! -e "$f" ] && [ ! -L "$f" ]; then
        echo "trash: cannot find '$f'" >&2
        continue
      fi
      case "$f" in
        *.lfmount)
          fusermount3 -uz -- "$f" 2>/dev/null || umount -l -- "$f" 2>/dev/null || true
          ;;
      esac
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
  '';
in
{
  home.packages = with pkgs; [
    trash
    jq
    poppler-utils # pdftotext
    highlight
    chafa # sixel images
    ffmpegthumbnailer # video thumbnails
    fuse-archive # browse into archives without extracting
    _7zz
    nsxiv
    xrdb
  ];

  xresources.properties = {
    "Nsxiv.window.background" = "#${config.lib.stylix.colors.base00}";
    "Nsxiv.window.foreground" = "#${config.lib.stylix.colors.base05}";
  };

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
      mouse = true;
    };

    keybindings = {
      D = "push :confirm-delete<space>";
      d = "push :confirm-trash<space>";
      i = "$less $f";
      gc = "cd ${config.flakeDir}";
      gd = "cd ~/Downloads";
      gb = "cd ~/.local/share/bottles/bottles/test/drive_c";
      gg = "top --";
      gG = "bottom --";
      gm = "cd /run/media/${config.user}";
      a = "push :create<space>";
      A = "push :compress<space>";
      w = "$" + config.shell;
      x = "cut";
      Y = "copy-file";
      e = ''$$EDITOR "$f"'';
      E = "push :confirm-extract<space>";
      C = "copyto";
      M = "moveto";
      r = "rename-smart";
      T = "grid-select";
      P = "set preview!";
      "<c-c>" = "quit";
      "<c-f>" = ''$lf -remote "send $id select \"$(fzf)\""'';
      "<tab>" = "!du -sh";
      "<enter>" = "open";
      "<esc>" = ":unselect; clear";
      "." = "set hidden!";
      R = "reload && redraw";
    };

    commands = {
      copy-file = ''$wl-copy -t text/uri-list "file://$(realpath $f)"'';
      on-init = "";

      on-quit = ''
        ''${{
          mount | grep -E '\.lfmount ' | awk '{print $3}' | while IFS= read -r m; do
            fusermount3 -uz -- "$m" 2>/dev/null || umount -l -- "$m" 2>/dev/null
            rmdir -- "$m" 2>/dev/null
          done
        }}'';

      open = ''
        ''${{
          case "$(file -Lb --mime-type -- "$f")" in
            text/* | application/json | application/x-subrip | inode/x-empty)
              $EDITOR "$f"
              ;;
            application/zip | application/x-zip* | application/x-tar | application/gzip | application/x-gzip | application/x-bzip2 | application/x-bzip | application/x-xz | application/x-7z-compressed | application/vnd.rar | application/x-rar-compressed | application/x-lzma | application/x-compress)
              mnt="$(dirname -- "$f")/.$(basename -- "$f").lfmount"
              if ! mkdir -p "$mnt" 2>/dev/null; then
                mnt="''${XDG_RUNTIME_DIR:-/tmp}/lf-archive-mounts/$(realpath -- "$f" | md5sum | cut -d' ' -f1)"
                mkdir -p "$mnt"
              fi
              if ! mountpoint -q "$mnt"; then
                if ! fuse-archive "$f" "$mnt" 2>>"''${XDG_RUNTIME_DIR:-/tmp}/lf-archive-mount.log"; then
                  xdg-open "$f" > /dev/null 2>&1 &
                  exit 0
                fi
              fi
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
          name="$1"
          [ -z "$name" ] && exit 0
          mapfile -t files <<< "$fx"
          dir=$(dirname -- "''${files[0]}")
          names=()
          for f in "''${files[@]}"; do
            names+=("$(basename -- "$f")")
          done
          out="$PWD/$name"
          case "$name" in
            *.tar.gz) (cd "$dir" && ${lib.getExe pkgs.gnutar} -czf "$out" -- "''${names[@]}") ;;
            *.zip) (cd "$dir" && ${lib.getExe pkgs._7zz} a "$out" -- "''${names[@]}") ;;
            *) lf -remote "send $id echoerr 'name must end in .tar.gz or .zip'" ;;
          esac
          lf -remote "send $id reload"
        }}'';

      confirm-extract = ''
        ''${{
          case "$1" in "" | y | Y) ;; *) exit 0 ;; esac
          [ -z "$fx" ] && exit 0
          mapfile -t files <<< "$fx"
          for f in "''${files[@]}"; do
            case "$f" in
              *.tar.gz | *.tgz) ${lib.getExe pkgs.gnutar} -xzf "$f" ;;
              *.tar.bz2 | *.tbz2) ${lib.getExe pkgs.gnutar} -xjf "$f" ;;
              *.tar.xz | *.txz) ${lib.getExe pkgs.gnutar} -xJf "$f" ;;
              *.tar) ${lib.getExe pkgs.gnutar} -xf "$f" ;;
              *.rar) ${lib.getExe pkgs.unar} "$f" ;;
              *) ${lib.getExe pkgs._7zz} x "$f" ;;
            esac
          done
          lf -remote "send $id reload"
        }}'';

      confirm-trash = ''
        ''${{
          case "$1" in "" | y | Y) ;; *) exit 0 ;; esac
          [ -z "$fx" ] && exit 0
          mapfile -t files <<< "$fx"
          trash -y -- "''${files[@]}"
          lf -remote "send $id reload"
        }}'';

      confirm-delete = ''
        ''${{
          case "$1" in "" | y | Y) ;; *) exit 0 ;; esac
          [ -z "$fx" ] && exit 0
          mapfile -t files <<< "$fx"
          for it in "''${files[@]}"; do
            case "$it" in
              *.lfmount) fusermount3 -uz -- "$it" 2>/dev/null || umount -l -- "$it" 2>/dev/null || true ;;
            esac
          done
          rm -rf -- "''${files[@]}"
          lf -remote "send $id reload"
        }}'';

      create = ''
        ''${{
          name="$1"
          [ -z "$name" ] && exit 0
          if [ "''${name: -1}" = "/" ]; then
            mkdir -p -- "$name"
          else
            case "$name" in
              */*) mkdir -p -- "''${name%/*}" ;;
            esac
            touch -- "$name"
          fi
          lf -remote "send $id reload"
        }}'';

      paste = ''
        ''${{
          lf_files="''${XDG_DATA_HOME:-$HOME/.local/share}/lf/files"
          [ -f "$lf_files" ] || exit 0
          mode=$(head -1 "$lf_files")
          files=$(tail -n +2 "$lf_files")
          [ -z "$files" ] && exit 0
          printf '%s\n' "$files" | while IFS= read -r src; do
            [ -z "$src" ] && continue
            name=$(basename -- "$src")
            dst="$PWD/$name"
            n=1
            while [ -e "$dst" ]; do
              dst="$PWD/$name.$n"
              n=$((n + 1))
            done
            [ "$mode" = "move" ] && mv -- "$src" "$dst" || cp -r -- "$src" "$dst"
          done
          [ "$mode" = "move" ] && lf -remote "send clear"
          lf -remote "send $id reload"
        }}'';

      grid-select = ''
        ''${{
          xrdb -merge ~/.Xresources 2>/dev/null
          sel=$(nsxiv -t -o -- "$PWD" 2>/dev/null)
          [ -z "$sel" ] && exit 0
          lf -remote "send $id unselect"
          printf '%s\n' "$sel" | while IFS= read -r p; do
            [ -z "$p" ] && continue
            lf -remote "send $id select \"$p\""
            lf -remote "send $id toggle"
          done
        }}'';

      moveto = ''
        ''${{
          [ -z "$fx" ] && exit 0
          dest=$(fd --type d . "$HOME" 2>/dev/null | fzf --prompt="move to: ")
          [ -z "$dest" ] && exit 0
          mapfile -t files <<< "$fx"
          for src in "''${files[@]}"; do
            mv -- "$src" "$dest/"
          done
          lf -remote "send $id reload"
        }}'';

      copyto = ''
        ''${{
          [ -z "$fx" ] && exit 0
          dest=$(fd --type d . "$HOME" 2>/dev/null | fzf --prompt="copy to: ")
          [ -z "$dest" ] && exit 0
          mapfile -t files <<< "$fx"
          for src in "''${files[@]}"; do
            cp -r -- "$src" "$dest/"
          done
          lf -remote "send $id reload"
        }}'';

      rename-smart = ''
        ''${{
          count=$(echo "$fx" | grep -c .)
          if [ "$count" -le 1 ]; then
            lf -remote "send $id rename"
          else
            lf -remote "send $id bulk-rename"
          fi
        }}'';

      bulk-rename = ''
        ''${{
          [ -z "$fx" ] && exit 0
          tmpfile=$(mktemp /tmp/lf-rename.XXXXXX)
          echo "$fx" | while IFS= read -r f; do
            basename -- "$f"
          done > "$tmpfile"
          orig_count=$(wc -l < "$tmpfile")
          $EDITOR "$tmpfile"
          new_count=$(wc -l < "$tmpfile")
          if [ "$orig_count" -ne "$new_count" ]; then
            lf -remote "send $id echoerr 'bulk-rename: line count changed ('"$orig_count"' -> '"$new_count"'), aborting'"
            rm -f "$tmpfile"
            exit 1
          fi
          dir=$(dirname "$(echo "$fx" | head -1)")
          i=0
          echo "$fx" | while IFS= read -r src; do
            i=$((i + 1))
            newname=$(sed -n "''${i}p" "$tmpfile")
            [ -z "$newname" ] && continue
            [ "$(basename -- "$src")" = "$newname" ] && continue
            dst="$dir/$newname"
            n=1
            while [ -e "$dst" ]; do
              dst="$dir/$newname.$n"
              n=$((n + 1))
            done
            mv -- "$src" "$dst"
          done
          rm -f "$tmpfile"
          lf -remote "send $id reload"
        }}'';

      get-mime-type = ''%xdg-mime query filetype \"$f\"'';
    };

    previewer.source = lib.getExe pkgs.pistol;
  };
}
