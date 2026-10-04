{
  config,
  lib,
  ...
}:
let
  cfg = config.services.oa-healthcheck;
  admincli = if cfg.package != null then "${cfg.package}/bin/admincli" else cfg.executable;
in
{
  options.services.oa-healthcheck = {
    enable = lib.mkEnableOption "OA outside-in health watcher";

    package = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = null;
      description = ''
        Package providing the admincli binary. Null falls back to
        `executable`, for an imperatively installed admincli.
      '';
    };

    executable = lib.mkOption {
      type = lib.types.str;
      default = "%h/.local/share/go/bin/admincli";
      example = "%h/.nix-profile/bin/admincli";
      description = ''
        admincli path, used when `package` is null. Defaults to GOPATH/bin
        for a `go install ./cmd/admincli` build; override for a nix profile
        install or a different GOPATH.

        systemd resolves bare names only against a compiled-in search path,
        which on NixOS contains neither nix profiles nor the user's PATH, so
        this has to be absolute or use a specifier like %h.
      '';
    };

    domainsFile = lib.mkOption {
      type = lib.types.path;
      description = ''
        File listing the domains to check, one per line or comma separated
        (# comments allowed); api.<domain> is derived.
      '';
    };

    readyzKeyFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        File containing the /readyz API key. Without it only liveness is
        checked, which cannot see a dead database.
      '';
    };

    xmppJIDFile = lib.mkOption {
      type = lib.types.path;
      description = "File containing the bot account, user@domain.";
    };

    xmppPasswordFile = lib.mkOption {
      type = lib.types.path;
      description = "File containing the bot password.";
    };

    xmppToFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        File listing JIDs to alert. Null sends to the bot's own JID.
      '';
    };

    interval = lib.mkOption {
      type = lib.types.str;
      default = "2min";
      description = "Gap between rounds.";
    };

    failuresBeforeAlert = lib.mkOption {
      type = lib.types.int;
      default = 2;
      description = "Consecutive failing rounds before the first message.";
    };

    repeatInterval = lib.mkOption {
      type = lib.types.str;
      default = "1h";
      description = "Minimum gap between reminders while still failing.";
    };
  };

  config = lib.mkMerge [
    {
      services.oa-healthcheck = {
        enable = true;
        domainsFile = "/run/secrets/oa-domains";
        xmppJIDFile = "/run/secrets/oa-xmpp-jid";
        xmppPasswordFile = "/run/secrets/oa-xmpp-password";
        readyzKeyFile = "/run/secrets/readyz_api_key";
      };
    }
    (lib.mkIf cfg.enable {
      systemd.user.services."oa-healthcheck" = {
        Unit = {
          Description = "OA health watcher";
          After = [ "network-online.target" ];
        };

        Service = {
          Type = "simple";
          ExecStart = lib.concatStringsSep " " (
            [
              admincli
              "watch"
              "--daemon"
              "--interval ${cfg.interval}"
              "--failures ${toString cfg.failuresBeforeAlert}"
              "--repeat ${cfg.repeatInterval}"
              "--domains-file ${cfg.domainsFile}"
              "--xmpp-jid-file ${cfg.xmppJIDFile}"
              "--xmpp-password-file ${cfg.xmppPasswordFile}"
            ]
            ++ lib.optional (cfg.xmppToFile != null) "--xmpp-to-file ${cfg.xmppToFile}"
            ++ lib.optional (cfg.readyzKeyFile != null) "--readyz-key-file ${cfg.readyzKeyFile}"
          );

          Restart = "always";
          RestartSec = "60s";
        };

        Install.WantedBy = [ "default.target" ];
      };
    })
  ];
}
