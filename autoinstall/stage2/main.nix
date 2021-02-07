self: pkgs: {
  # Autoinstall script
  packages.x86_64-linux.autoinstall = pkgs.writeScriptBin "autoinstall" (''
#!${pkgs.stdenv.shell}

PATH=${pkgs.dmidecode}/bin:$PATH
PATH=${pkgs.gawk}/bin:$PATH
PATH=${pkgs.parted}/bin:$PATH
PATH=${pkgs.cryptsetup}/bin:$PATH
PATH=${pkgs.e2fsprogs}/bin:$PATH
PATH=${pkgs.btrfs-progs}/bin:$PATH
PATH=${pkgs.dosfstools}/bin:$PATH
PATH=${pkgs.git}/bin:$PATH
PATH=${pkgs.utillinux}/bin:$PATH
PATH=/run/wrappers/bin:$PATH # mount
PATH=${(pkgs.nixos {}).nixos-install}/bin:$PATH # nixos-install
export PATH

'' + (builtins.readFile ./autoinstall.sh));

  # Expose package above for 'nix run .#autoinstall'
  apps.x86_64-linux.autoinstall = {
    type = "app";
    program = "${self.packages.x86_64-linux.autoinstall}/bin/autoinstall";
  };

}
