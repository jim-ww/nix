{ pkgs, ... }:
{
  programs.bemenu = {
    enable = true;

    # plain left/right move the text cursor upstream; remap them to page
    # up/down (shift+left/right jumps to top/bottom) so paging through a
    # long list doesn't require holding up/down.
    package = pkgs.bemenu.overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ [ ./bemenu-leftright-page.patch ];
    });

    settings = {
      center = true;
      width-factor = 0.15;
      line-height = 30;
      border = 1;
      border-radius = 4;
      ignorecase = true;
      list = 15;
      prompt = "";
    };
  };
}
