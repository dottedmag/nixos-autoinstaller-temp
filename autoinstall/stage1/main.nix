{config, pkgs, ...}: {
  config = {
    # Significant speedup of image build
    isoImage.squashfsCompression = "zstd";

    # To resolve mDNS names during installation
    services.avahi = {
      enable = true;
      nssmdns = true;
    };

    # To enable 'nix run' and flakes
    nix.package = pkgs.nixUnstable;
    nix.extraOptions = ''
      experimental-features = nix-command flakes
    '';

    systemd.services.autoinstall = {
      wantedBy = ["multi-user.target"];
      # pkgs.nixUnstable, pkgs.git -- for "nix run"
      # pkgs.kbd -- for "chvt"
      path = [pkgs.kbd pkgs.wget pkgs.nixUnstable pkgs.git];
      script = builtins.readFile ./download-run.sh;
      serviceConfig = {
        Type = "idle";
        StandardInput = "tty";
        StandardOutput = "tty";
        TTYPath = "/dev/tty7";
      };
    };
  };
}
