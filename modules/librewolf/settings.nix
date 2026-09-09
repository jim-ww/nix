{
  "webgl.disabled" = false;
  "privacy.resistFingerprinting" = false;
  # "privacy.resistFingerprinting.letterboxing" = false;
  "dom.security.https_only_mode" = false;
  "fission.autostart" = true;
  "media.peerconnection.enabled" = false;
  "network.IDN_show_punycode" = true;
  "image.jxl.enabled" = true;

  "layout.css.prefers-color-scheme.content-override" = 0; # Dark mode

  "privacy.clearOnShutdown.history" = false;
  "privacy.clearOnShutdown.cookies" = false;
  "privacy.clearOnShutdown.openWindows" = false;
  "privacy.clearOnShutdown.sessions" = false;
  "privacy.clearOnShutdown.downloads" = false;
  "privacy.clearOnShutdown.formdata" = true;
  "privacy.clearOnShutdown_v2.formdata" = true;
  "privacy.sanitize.sanitizeOnShutdown" = false;
  "privacy.clearOnShutdown_v2.cookiesAndStorage" = false;
  "privacy.clearOnShutdown_v2.cache" = false;
  "privacy.clearSiteData.formdata" = true;

  "network.cookie.lifetimePolicy" = 0;
  "browser.startup.page" = 3;
  "browser.aboutwelcome.enabled" = false;
  "browser.discovery.enabled" = false;
  "browser.aboutConfig.showWarning" = false;

  # Firefox Sync
  "identity.fxaccounts.enabled" = false;
  "signon.rememberSignons" = false;
  "extensions.formautofill.addresses.enabled" = false;
  "extensions.formautofill.creditCards.enabled" = false;

  "browser.bookmarks.addedImportButton" = false;
  "browser.bookmarks.showMobileBookmarks" = true;

  "browser.download.useDownloadDir" = true;
  # "browser.download.dir" = config.xdg.userDirs.download;
  "browser.download.always_ask_before_handling_new_types" = false;

  "browser.fullscreen.autohide" = false;
  "browser.toolbars.bookmarks.visibility" = "never"; # "always";
  "browser.quitShortcut.disabled" = true;

  "ui.use_activity_cursor" = true;
  "findbar.highlightAll" = true;

  # Don't allow websites to prevent use of right-click, clipboard
  "dom.event.contextmenu.enabled" = true;
  "dom.event.clipboardevents.enabled" = true;

  "browser.ctrlTab.sortByRecentlyUsed" = false;

  # new tab page, shortcuts
  "browser.newtabpage.enabled" = false;
  "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;

  "sidebar.revamp" = true;
  "sidebar.verticalTabs" = true;
  "sidebar.main.tools" = ""; # "aichat,history";
  "sidebar.visibility" = "expand-on-hover"; # "always-show"; #"hide-sidebar";
  "sidebar.expandOnHover" = true;
  "sidebar.animation.enabled" = false;
  "sidebar.animation.expand-on-hover.delay-duration-ms" = 0; # def: 200
  "sidebar.animation.expand-on-hover.duration-ms" = 0; # ? def: 400
  "browser.engagement.sidebar-button.has-used" = true; # ???
  "sidebar.new-sidebar.has-used" = true;
  "browser.toolbarbuttons.introduced.sidebar-button" = true; # ???
  "sidebar.verticalTabs.dragToPinPromo.dismissed" = true;
  #"sidebar.backupState" = ''{"command":"","panelOpen":false,"panelWidth":215,"launcherWidth":0,"expandedLauncherWidth":139,"launcherExpanded":false,"launcherVisible":false}'';

  "svg.context-properties.content.enabled" = true; # for simple tab groups extension to use dark mode

  # Scroll speed
  "mousewheel.min_line_scroll_amount" = 30; # def 5

  # Translations
  "browser.translations.enable" = true;
  "browser.translations.automaticallyPopup" = true;
  "browser.translations.mostRecentTargetLanguages" = "en";
  "browser.translations.neverTranslateLanguages" = "ru";
  "browser.translations.alwaysTranslateLanguages" = "ja";
  "browser.translations.newSettingsUI.enable" = true;

  # "browser.newtabpage.activity-stream.feeds.topsites" = false; # disable shortcuts at all
  #"browser.newtabpage.blocked" =
  # "{\"eV8/WsSLxHadrTL1gAxhug==\":1,\"T9nJot5PurhJSy8n038xGA==\":1,\"gLv0ja2RYVgxKdp0I5qwvA==\":1,\"4gPpjkxgZzXPVtuEoAL9Ig==\":1}"; # disable only wiki, twitter, facebook, etc

  /*
    "browser.uiCustomization.state" =
    "{\"placements\":{\"widget-overflow-fixed-list\":[],\"unified-extensions-area\":[\"idcac-pub_guus_ninja-browser-action\",\"_a6c4a591-f1b2-4f03-b3ff-767e5bedf4e7_-browser-action\",\"_b86e4813-687a-43e6-ab65-0bde4ab75758_-browser-action\"],\"nav-bar\":[\"back-button\",\"forward-button\",\"stop-reload-button\",\"customizableui-special-spring1\",\"vertical-spacer\",\"urlbar-container\",\"customizableui-special-spring2\",\"save-to-pocket-button\",\"downloads-button\",\"fxa-toolbar-menu-button\",\"unified-extensions-button\",\"_278b0ae0-da9d-4cc6-be81-5aa7f3202672_-browser-action\",\"ublock0_raymondhill_net-browser-action\",\"jid1-mnnxcxisbpnsxq_jetpack-browser-action\",\"keepassxc-browser_keepassxc_org-browser-action\",\"addon_darkreader_org-browser-action\"],\"toolbar-menubar\":[\"menubar-items\"],\"TabsToolbar\":[\"firefox-view-button\",\"tabbrowser-tabs\",\"new-tab-button\",\"alltabs-button\"],\"vertical-tabs\":[],\"PersonalToolbar\":[\"import-button\",\"personal-bookmarks\"]},\"seen\":[\"developer-button\",\"_278b0ae0-da9d-4cc6-be81-5aa7f3202672_-browser-action\",\"idcac-pub_guus_ninja-browser-action\",\"addon_darkreader_org-browser-action\",\"ublock0_raymondhill_net-browser-action\",\"keepassxc-browser_keepassxc_org-browser-action\",\"_a6c4a591-f1b2-4f03-b3ff-767e5bedf4e7_-browser-action\",\"jid1-mnnxcxisbpnsxq_jetpack-browser-action\",\"_b86e4813-687a-43e6-ab65-0bde4ab75758_-browser-action\"],\"dirtyAreaCache\":[\"nav-bar\",\"vertical-tabs\",\"unified-extensions-area\",\"PersonalToolbar\"],\"currentVersion\":21,\"newElementCount\":2}";
  */
  # Theme
  # "browser.display.background_color" = config.lib.stylix.colors.base01;
  # "browser.display.foreground_color" = config.lib.stylix.colors.base04;
  # "browser.display.use_system_colors" = true;
}
