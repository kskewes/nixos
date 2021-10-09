# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  # Enable support for nix flakes - remove when `nix --version` >= 2.4
  nix.package = pkgs.nixFlakes;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  # system user
  users.users.karl = {
    home = "/home/karl";
    isNormalUser = true;
    extraGroups = [ "audio" "docker" "wheel" ];
    # nix-shell -p mkpasswd
    # vim -> :read !mkpasswd -m sha-512
    # hashedPassword = "";
  };
  # Users password/etc are set from source
  users.mutableUsers = false;

  # Set your time zone.
  time.timeZone = "Pacific/Auckland";

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    gnumake
    home-manager
    xclip
    vim
    wget
  ];

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Still problematic in 2021
  networking.enableIPv6 = false;

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  # set network interface in ${machine}.nix
  # :read !ip link | grep ': en'
  # networking.interfaces.ens33.useDHCP = true;

  networking.firewall.enable = true;
  # networking.firewall.allowedTCPPorts (https://nixos.org/manual/nixos/stable/options.html#opt-networking.firewall.allowedTCPPorts) = [ 22 ];
  # networking.firewall.allowedTCPPortRanges (https://nixos.org/manual/nixos/stable/options.html#opt-networking.firewall.allowedTCPPortRanges) = [
  #  { from = 4000; to = 4007; }
  #  { from = 8000; to = 8010; }
  # ];
  # networking.firewall.allowedUDPPorts = [];
  # networking.firewall.allowedUDPPortRanges = [];

  nix = {
    # only allow users with sudo access ability to access nix daemon
    allowedUsers = [ "@wheel" ];

    # TODO: Enable when not experimental?
    # autoOptimiseStore = true;
    # automatically trigger garbage collection
    gc = {
      automatic = true;
      persistent = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  security.sudo.wheelNeedsPassword = false;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.passwordAuthentication = false;
  services.openssh.permitRootLogin = "no";

  # Virtualization settings
  virtualisation.docker.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?
}
