{ config, lib, ... }:

{
  options.zfsBootUnlock = {
    enable = lib.mkEnableOption "zfsBootUnlock";

    authorizedKeys = lib.mkOption {
      default = [ ];
      type = with lib.types; listOf str;
      description = ''
        SSH AuthorizedKeys.
      '';
    };

    interfaces = lib.mkOption {
      default = [ ];
      type = with lib.types; listOf str;
      description = ''
        Network interfaces to enable DCHP on.
      '';
    };
  };

  config = {
    assertions = lib.mkIf config.zfsBootUnlock.enable [
      {
        assertion = lib.length (config.zfsBootUnlock.authorizedKeys) > 0;
        message = "zfsBootUnlock.authorizedKeys required to login via ssh";
      }
      {
        assertion = lib.length (config.zfsBootUnlock.interfaces) > 0;
        message = "zfsBootUnlock.interfaces required to enable dhcp on";
      }
    ];

    boot = {
      kernelParams = [ "nohibernate" ]; # not supported by zfs
      supportedFilesystems = [ "zfs" ];
      zfs.devNodes = "/dev/disk/by-path";
      zfs.requestEncryptionCredentials = true; # prompt for encryption password

      # https://nixos.wiki/wiki/ZFS#Remote_unlock
      initrd = lib.mkIf config.zfsBootUnlock.enable {
        # :read !sudo lshw -C network | grep --only-matching "driver=\S*"
        availableKernelModules = config.zfsBootUnlock.interfaces;
        network = {
          # This will use udhcp to get an ip address.
          enable = true;
          ssh = {
            enable = true;
            port = 2222;
            # hostKeys paths must be unquoted strings, otherwise you'll run into issues with boot.initrd.secrets
            # the keys are copied to initrd from the path specified; multiple keys can be set
            # you can generate any number of host keys using
            # `ssh-keygen -t ed25519 -N "" -f /path/to/ssh_host_ed25519_key`
            hostKeys = [ /etc/ssh/ssh_host_ed25519_key ];
            authorizedKeys = config.zfsBootUnlock.authorizedKeys;
            # Unlock with:
            # host=<IP> ssh -p 2222 root@"${host}" "zpool import -a; zfs load-key -a && killall zfs"
          };
        };
      };
    };

    nixpkgs.config.allowBroken = true; # Package ‘zfs-kernel-2.2.4-6.9.9-asahi’

    services.zfs = {
      autoScrub.enable = true;
      autoSnapshot.enable = true;
      trim.enable = true;
    };

    virtualisation.docker = { storageDriver = lib.mkDefault "zfs"; };
  };
}
