{
  force = true;
  default = "ddg";
  engines = {
    "google".metaData.hidden = true;
    "amazondotcom-us".metaData.hidden = true;
    "bing".metaData.hidden = true;
    "ebay".metaData.hidden = true;
    "wikipedia".metaData.hidden = true; # alias = "@w";
    "Presearch" = {
      urls = [
        {
          template = "https://presearch.com/";
          params = [
            {
              name = "q";
              value = "{searchTerms}";
            }
          ];
        }
      ];
      definedAliases = [ "@pr" ];
    };
    "Mullvad" = {
      urls = [
        {
          template = "https://leta.mullvad.net/";
          params = [
            {
              name = "q";
              value = "{searchTerms}";
            }
          ];
        }
      ];
      definedAliases = [ "@mv" ];
    };

    "GitHub" = {
      urls = [
        {
          template = "https://github.com/search";
          params = [
            {
              name = "q";
              value = "{searchTerms}";
            }
          ];
        }
      ];
      definedAliases = [ "@gh" ];
    };

    "Nix" = {
      urls = [
        {
          template = "https://search.nixos.org/packages";
          params = [
            {
              name = "channel";
              value = "unstable";
            }
            {
              name = "query";
              value = "{searchTerms}";
            }
          ];
        }
      ];
      # icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
      definedAliases = [ "@np" ];
    };
    "Home Manager" = {
      urls = [
        {
          template = "https://home-manager-options.extranix.com/";
          params = [
            {
              name = "query";
              value = "{searchTerms}";
            }
            {
              name = "release";
              value = "master";
            }
          ];
        }
      ];
      definedAliases = [ "@hm" ];
    };
    "Nixpkgs Issues" = {
      urls = [
        {
          template = "https://github.com/NixOS/nixpkgs/issues";
          params = [
            {
              name = "q";
              value = "{searchTerms}";
            }
          ];
        }
      ];
      definedAliases = [ "@ni" ];
    };
    "Python packages" = {
      urls = [
        {
          template = "https://pypi.org/search/";
          params = [
            {
              name = "q";
              value = "{searchTerms}";
            }
          ];
        }
      ];
    };
    "AI Chat" = {
      urls = [
        {
          template = "https://duckduckgo.com/?q=!chat+{searchTerms}";
        }
      ];
      definedAliases = [ "@ai" ];
    };
  };
}
