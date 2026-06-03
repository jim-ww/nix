{pkgs, ...}: {
  stylix.targets.librewolf.profileNames = ["default"];

  programs.librewolf = {
    enable = true;
    settings = import ./settings.nix;
    profiles.default = {
      search = import ./search.nix;
      extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
        ublock-origin
        keepassxc-browser
        darkreader
        single-file
        # proton-vpn
        # yomitan # Japanese
        # disabled:
        #ipfs-companion
        # violentmonkey
        # mullvad
        # istilldontcareaboutcookies
        # vimium
        # libredirect
        # privacy-badger
        # proton-vpn
        # youtube-shorts-block
        # re-enable-right-click
        # user-agent-string-switcher
        # localcdn
        # react-devtools
        # reduxdevtools
        # vue-js-devtools
        # unpaywall
        # immersive-translate # proprietary
        # tunnelbear-vpn-firefox # proprietary

        # missing:
        # alpinejs-devtools
        # 10ten-ja-reader
        # new-tab-same-group
        # lighthouse
      ];
      #userChrome = "";
      #userContent = "";
    };
    #nativeMessagingHosts = [];
    # policies = {};
  };
}
