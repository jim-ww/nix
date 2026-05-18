{ pkgs, ... }:
{
  home.packages = [ pkgs.nom ];

  xdg.configFile."nom/config.yml" = {
    enable = true;
    text = ''
      showread: false
      showfavourite: true
      autoread: true
      feeds:
        - url:  http://blog.golang.org/feed.atom
          name: go-blog
        - url: https://www.linux.org.ru/section-rss.jsp?section=1
          name: linux.org.ru
        - url: https://notrelated.xyz/rss
          name: luke-smith
        - url: https://monero.town/feeds/local.xml?sort=Active
          name: monero.town
        - url: https://www.getmonero.org/feed.xml
          name: Monero (official blog)
        - url: https://onehack.st/latest.rss
          name: OneHack
    '';
  };
}
