{pkgs, ...}: {
  stylix.targets.librewolf.profileNames = ["default"];

  programs.librewolf = {
    enable = true;
    settings = import ./settings.nix;
    policies.SecurityDevices."eID Belgium" = "${pkgs.eid-mw}/lib/libbeidpkcs11.so";
    profiles.default = {
      search = import ./search.nix;
      extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
        ublock-origin
        keepassxc-browser
        single-file
        darkreader
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
