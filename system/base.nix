# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, currentRevision, currentUser, currentSystem, currentSystemName
, currentAuthorizedKeys, ... }:

{
  # system user
  users.users.${currentUser} = {
    home = "/home/${currentUser}";
    isNormalUser = true;
    extraGroups = [
      "audio"
      "docker"
      "libvirtd"
      "wheel"
      "scanner" # scanning
      "lp" # scanning
    ];
    # nix-shell -p mkpasswd
    # vim -> :read !mkpasswd -m sha-512
    # hashedPassword = "";
    openssh.authorizedKeys.keys = currentAuthorizedKeys;
  };
  # Users password/etc are set from source
  users.mutableUsers = false;

  time.timeZone = "Pacific/Auckland";

  boot = {
    loader.systemd-boot.enable = true;
    loader.systemd-boot.memtest86.enable = {
      "x86_64-linux" = true;
      "aarch64-linux" = false;
    }."${currentSystem}";
    loader.efi.canTouchEfiVariables = {
      "x86_64-linux" = true;
      "aarch64-linux" = false;
    }."${currentSystem}";
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git # can't build without it
    gnumake
    home-manager
    nix-diff # nix-diff /run/current-system ./result
    simple-scan # scanner
    xclip
    vim
    wget
  ];

  i18n = {
    defaultLocale = "en_US.UTF-8";
    inputMethod = {
      enabled = "ibus";
      ibus.engines = with pkgs.ibus-engines; [ mozc ];
    };
  };

  # Still problematic in 2021
  networking.enableIPv6 = false;
  networking.hostName = "${currentSystemName}";
  networking.nat.enableIPv6 = true;

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  # set network interface in ${machine}.nix
  # :read !ip link | grep ': en'
  # networking.interfaces.ens33.useDHCP = true;

  # FIXME: Firewall interferes with Kubernetes Kind inter-pod traffic.
  networking.firewall.enable = false;
  # networking.firewall.allowedTCPPorts (https://nixos.org/manual/nixos/stable/options.html#opt-networking.firewall.allowedTCPPorts) = [ 22 ];
  # networking.firewall.allowedTCPPortRanges (https://nixos.org/manual/nixos/stable/options.html#opt-networking.firewall.allowedTCPPortRanges) = [
  #  { from = 4000; to = 4007; }
  #  { from = 8000; to = 8010; }
  # ];
  # networking.firewall.allowedUDPPorts = [];
  # networking.firewall.allowedUDPPortRanges = [];

  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';

    settings = {
      # only allow users with sudo access ability to access nix daemon
      allowed-users = [ "@wheel" ];
      auto-optimise-store = true;
    };

    # automatically trigger garbage collection
    gc = {
      automatic = true;
      persistent = true;
      dates = "weekly";
      options = "--delete-older-than 8d";
    };
  };

  security.sudo.wheelNeedsPassword = false;

  services.fwupd = {
    enable = true;
    extraRemotes = [ "lvfs-testing" ];
  };

  services.logind = {
    lidSwitch = "ignore"; # default "suspend"
    lidSwitchDocked = "ignore";
    lidSwitchExternalPower = "ignore";
    extraConfig = ''
      IdleAction=lock
      IdleActionSec=3600
    '';
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  services.printing.enable = true;
  hardware.printers.ensurePrinters = [{
    name = "Brother";
    deviceUri = "ipp://BRW1CBFC0F36D0B/ipp";
    model = "everywhere";
  }];
  hardware.printers.ensureDefaultPrinter = "Brother";
  hardware.sane = {
    enable = {
      "x86_64-linux" = true;
      "aarch64-linux" = false;
    }."${currentSystem}";

    brscan4 = {
      enable = true;
      netDevices = {
        home = {
          model = "MFC-L2713DW";
          ip = "192.168.1.104";
          # nodename = "BRW1CBFC0F36D0B";
        };
      };
    };
    # brscan5 = { enable = true; };
  };
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
      userServices = true;
    };
  };

  # Let 'nixos-version --json' know about the Git revision
  # system.configurationRevision = currentRevision;

  # Docker seems to be more reliable for the containers running.
  virtualisation.docker = { enable = true; };
  virtualisation.oci-containers.backend = "docker";

  # virtualisation = {
  #   podman = {
  #     enable = true;
  #     extraPackages = [ pkgs.zfs ];
  #     dockerCompat = true;
  #   };
  # };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
}
