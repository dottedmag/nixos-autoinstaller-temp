{
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-20.09;
    nix = {
      url = github:NixOS/nix/45645b6f3b6c45f20a7bece6da395c3e095aedd0;
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = github:dottedmag/home-manager/release-20.09;
      inputs.nipkgs.follows = "nixpkgs";
    };
    emacs-overlay.url = github:nix-community/emacs-overlay;
  };

  outputs = {self, nixpkgs, home-manager, nix, emacs-overlay}:
    let pkgs = import nixpkgs {system = "x86_64-linux";};
    in
    {
    nixosConfigurations = {
      # .#nixosConfigurations.installer.config.system.build.isoImage
      installer = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
          ./autoinstall/stage1/main.nix
          ./pieces/console-kbd-layout.nix
          ({pkgs, ...}: {
            console.font = "${pkgs.terminus_font}/share/consolefonts/ter-v22n";
          })
        ];
      };
      parallels = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          (if builtins.pathExists ./overlay.nix then ./overlay.nix else {})
          (import ./configuration.nix emacs-overlay)
          ./parallels.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.dottedmag = import ./home.nix;
          }
        ];
      };
    };
  } // (import ./autoinstall/stage2/main.nix self pkgs);
}
