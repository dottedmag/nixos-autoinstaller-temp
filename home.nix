{pkgs, ...}:
let
  emacs = (pkgs.emacsPackagesGen pkgs.emacsPgtk).emacsWithPackages (
    epkgs: [
      epkgs.melpaStablePackages.go-mode
      epkgs.melpaStablePackages.magit
      epkgs.melpaStablePackages.yaml-mode
      epkgs.melpaStablePackages.markdown-mode
      epkgs.melpaStablePackages.json-mode
      epkgs.melpaStablePackages.flycheck
      epkgs.melpaStablePackages.which-key
      epkgs.orgPackages.org
    ]
  );
in
{
  home.packages = [
    emacs
    pkgs.htop
    pkgs.firefox
    pkgs.xdg_utils # For Firefox to set/check default browser
    pkgs.pstree
    pkgs.dmenu-wayland
    pkgs.jq
  ];
  home.file = {
    ".config/sway/config".source = ./dotfiles/sway-config;

    ".docker/config.json".source = ./dotfiles/docker-config.json;
    ".gitattributes".source = ./dotfiles/gitattributes;
    ".gitconfig".source = ./dotfiles/gitconfig;
    ".gitconfig.local".source = ./dotfiles/gitconfig.local.default;
    ".hushlogin".text = "";
    ".screenrc".source = ./dotfiles/screenrc;
    ".zshenv".source = ./dotfiles/zshenv;
    ".zshrc".source = ./dotfiles/zshrc;
    ".config/emacs/init.el".source = ./dotfiles/emacs/init.el;
    ".config/emacs/frame-init.el".source = ./dotfiles/emacs/frame-init.el;
    ".config/emacs/go.el".source = ./dotfiles/emacs/go.el;
    ".config/emacs/navigation.el".source = ./dotfiles/emacs/navigation.el;
    ".config/alacritty/alacritty.yml".source = ./dotfiles/alacritty.yml;

    ".config/xkb/compat/default".source = ./dotfiles/xkb/compat/default;
    ".config/xkb/keycodes/evdev".source = ./dotfiles/xkb/keycodes/evdev;
    ".config/xkb/rules/evdev".source = ./dotfiles/xkb/rules/evdev;
    ".config/xkb/types/default".source = ./dotfiles/xkb/types/default;
    ".config/xkb/symbols/layouts".source = ./dotfiles/xkb/symbols/layouts;
    ".config/xkb/symbols/variants".source = ./dotfiles/xkb/symbols/variants;
  };
}
