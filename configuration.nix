emacs-overlay: { config, pkgs, lib, ... }:

{
  system.stateVersion = "20.08";

  require = [
    ./pieces/console-kbd-layout.nix
  ];

  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  swapDevices = [ ];

  nix.maxJobs = lib.mkDefault 4;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  networking.useDHCP = false;

  console = {
    font = "${pkgs.terminus_font}/share/consolefonts/ter-v22n";
  };

  environment.systemPackages = [pkgs.terminus_font pkgs.molly-guard];

  virtualisation.docker.enable = true;

  services.openssh.enable = true;
  services.openssh.permitRootLogin = "yes";

  services.avahi = {
    enable = true;
    publish = {
      enable = true;
      # Publish this host's .local name
      addresses = true;
    };
    # Resolve .local names
    nssmdns = true;
  };

  networking.firewall.enable = true;

  sound.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.package = pkgs.pulseaudioFull;

  hardware.bluetooth.enable = true;

  users.mutableUsers = false;
  users.users = {
    dottedmag = {
      isNormalUser = true;
      uid = 1000;
      extraGroups = ["wheel" "docker"];
      packages = [
        pkgs.zsh
      ];
      shell = pkgs.zsh;
    };
  };

  programs.zsh.enable = true;

  programs.sway.enable = true;

  security.sudo.wheelNeedsPassword = false;

  services.flatpak.enable = true;
  xdg.portal.enable = true;

  nix.package = pkgs.nixUnstable;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  nixpkgs.overlays = [
    emacs-overlay.overlay
  ];
}
