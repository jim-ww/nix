{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  home = "/home/${config.user}";
  dataHome = "${home}/.local/share";
  videosDir = "${home}/Videos";
in
{
  config = {
    shellAliases =
      let
        ls = "ls -h --group-directories-first --color=auto";
        fzf = lib.getExe pkgs.fzf;
      in
      {
        v = "$EDITOR";
        c = "clear";
        rm = "rm -v";
        cp = "cp -v";
        mv = "mv -v";
        cc = "cd ${config.flakeDir} && l";
        ccc = "cd ${config.flakeDir} && $EDITOR $(${fzf})";
        l = ls;
        ls = ls;
        ll = "${ls} -l";
        la = "${ls} -A";
        ff = "fastfetch -s title:separator:os:wm:lm:terminal:shell:packages:uptime:datetime:battery:disk:memory:theme:wmtheme:colors";
        conf = "cd ${config.flakeDir} && $EDITOR hosts/nixos/configuration.nix";
        prefs = "cd ${config.flakeDir} && $EDITOR prefs.nix";
        flake = "cd ${config.flakeDir} && $EDITOR flake.nix";
        pkgs = "cd ${config.flakeDir} && $EDITOR pkgs.nix";
        ns = "nix-search";
        nsp = "nix-shell --run ${config.shell} -p";
        nix-store-fix = "sudo nix-store --repair --verify --check-contents";

        gs = "git status";
        gc = "git commit";
        ga = "git add";
        gaa = "git add --all";
        gl = "git log";
        gr = "git remote";
        gf = "git fetch";
        gi = "git init";
        gb = "git branch";
        gsw = "git switch";
        gd = "git diff";
        gcm = "git commit -m";
        gsm = "git stash -m";
        gwt = "git worktree";
        gcl = "git clone";
        gco = "git checkout";
        gps = "git push";
        gpl = "git pull";

        ani = "ani-cli";
        umu = "umu-run";
        http = "curlie";
        "7z" = "7zz";
        transcribe-translate-jp = "whisperx --device cpu --model base --compute_type int8 --language ja --output_format srt --output_dir . --no_align --task translate";
        busybox = lib.getExe pkgs.busybox;
        wf-record = ''wf-recorder -a --audio-backend=pipewire --codec h264_vaapi --device /dev/dri/renderD128 -p preset=ultrafast -f "${videosDir}/rec_$(date +%d-%m-%Y-T%H-%M-%S).mkv"''; # preset=fast
        mount-personal = "mkdir -p ~/Archive/personal && gocryptfs ~/Archive/personal_enc ~/Archive/personal";
        umount-personal = "umount ~/Archive/personal";
        backup-personal = ''tmux new -s backup "set -o pipefail; tar -cf - ${home}/Archive/personal | zstd -9 -T0 | ${lib.getExe pkgs.pv} | age -p -o ${home}/Downloads/backup-$(date +%Y%m%d).tar.zst.age && echo 'backup completed successfully' || echo 'backup FAILED'; read"'';
        trcli = "transmission-cli";
        trcli-rmt = ''transmission-remote $(cat /run/secrets/transmission-rpc-addr) -n "$(cat /run/secrets/transmission-rpc-user):$(cat /run/secrets/transmission-rpc-pass)"'';
        wg-update-ip = ''sed -i "s/ip = \"[^\"]*\"/ip = \"$(wl-paste)\"/" $NH_FLAKE/modules/wireguard.nix'';
        wg-clear-ip = ''sed -i "s/ip = \"[^\"]*\"/ip = \"\"/" $NH_FLAKE/modules/wireguard.nix'';
        hs = ''goeval 'log.Fatal(http.ListenAndServe(":8000", http.FileServer(http.Dir("."))))' '';
        yt-dlp = "yt-dlp --write-subs";
        itpec-sensei-mcp = "tmux new-session -s itpec-sensei-mcp 'NGROK_AUTHTOKEN=$(cat /run/secrets/ngrok-token) NGROK_RESERVED_URL=$(cat /run/secrets/ngrok-url) itpec-sensei serve --ngrok --remote'";
        bc = "busybox bc -q";
        gtr = "gtr -t ru";
        cld = ''
          tmux new-session -s "$(basename "$(pwd)")" -n shell \; \
                      new-window -n claude "bwrap-cwd claude" \; \
                      select-window -t 1'';
        tns = ''
          tmux new-session -s "$(basename "$(pwd)")" -n edit "$EDITOR ." \; \
                        new-window -n claude "bwrap-cwd claude" \; '';
        gomod2nix-init = "nix flake init -t github:nix-community/gomod2nix#app";
        xmr = "monero-wallet-cli --wallet-file $(cat /run/secrets/xmr-wallet) --daemon-address $(cat /run/secrets/xmr-daemon) --log-file ${home}/.cache/monero-wallet-cli.log";
        anitui = "anitui -status watching -sort last-watch -hide-airing -emit status,title,last,progress";
        todo = "todo -date-format 02-01-2006";
        restic = "restic --password-command 'sudo cat /run/secrets/restic-repo-password'";
        # shardic = "shardic --providers $(cat /run/secrets/shardic-providers)";
        snapshots-size = "sudo btrfs filesystem du -s /persistent/.snapshots/*/snapshot";
        jrnl = ''SOPS_AGE_KEY="$(sudo cat $SOPS_AGE_KEY_FILE)" sops ${home}/Documents/journal.md.age'';
        dns-fallback = "resolvectl dns wlo1 1.1.1.1";

        # unclutter home dir
        wget = ''${lib.getExe pkgs.wget} --hsts-file="${dataHome}/wget-hsts"'';
      };
  };
  options = {
    shellAliases = mkOption {
      type = types.attrsOf types.str;
    };
  };
}
