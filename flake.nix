{
  description = "NixOS Flake";

  inputs = {
    # use unstable by default for freshest packages, pin stable if need be.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "nixpkgs/nixos-21.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-21.05";
      # tell home-manager to use same packages as nixpkgs
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nightly-overlay.url = "github:mjlbach/neovim-nightly-overlay";

    nix-extra.url = "path:/home/karl/src/nix-extra";
    nix-extra.flake = false;
  };

  # pass all inputs to outputs
  outputs = { self, ... }@inputs:
    let

      # shared between home-manager and nixos
      system = "x86_64-linux";

      # Home Manager
      # https://github.com/nix-community/home-manager/blob/3d46c011d2cc2c9ca24d9b803e9daf156d9429ea/flake.nix#L54
      username = "karl";
      homeDirectory = "/home/${username}";
      stateVersion = "21.05"; # HACK for version mismatch error

      emailAddress = "karl.skewes@gmail.com";

      importsCommon = [
        ./home-manager/base.nix
        ./home-manager/dev.nix
        ./home-manager/xwindows.nix
      ];

      pkgs = import inputs.nixpkgs {
        inherit system;
        # required for chrome, perhaps could move elsewhere per machine/group
        config = { allowUnfree = true; };
      };

      lib = inputs.nixpkgs.lib;
      nixos-stable-overlay = final: prev: {
        stable = inputs.nixpkgs-stable.legacyPackages.${system};
      };
      overlaysCommon =
        [ nixos-stable-overlay inputs.neovim-nightly-overlay.overlay ];

      # NixOS
      modulesCommon = [
        "${inputs.nix-extra.outPath}/nixos.nix"
        ./machines/base.nix
        ./machines/xserver.nix
      ];

    in {
      homeManagerConfigurations = {
        karl-laptop = inputs.home-manager.lib.homeManagerConfiguration {
          inherit system pkgs username homeDirectory stateVersion;
          configuration = { config, pkgs, ... }: {
            nixpkgs.overlays = overlaysCommon;
            imports = importsCommon;
            home.packages = with pkgs; [ discord slack ];
            xresources.properties = { "Xft.dpi" = "109"; };
            programs.git.userEmail = emailAddress;
          };
        };

        karl-desktop = inputs.home-manager.lib.homeManagerConfiguration {
          inherit system pkgs username homeDirectory stateVersion;
          configuration = { config, pkgs, ... }: {
            nixpkgs.overlays = overlaysCommon;
            imports = importsCommon;
            home.packages = with pkgs; [ discord slack ];
            xresources.properties = { "Xft.dpi" = "109"; };
            programs.git.userEmail = emailAddress;
          };
        };

      };

      nixosConfigurations = {
        karl-desktop = lib.nixosSystem {
          inherit system;
          modules = modulesCommon ++ [
            ./machines/hardware-configuration-karl-desktop.nix
            ({ config, ... }: {
              # Let 'nixos-version --json' know about the Git revision
              system.configurationRevision = lib.mkIf (self ? rev) self.rev;
              # Define hostId for zfs pool machine 'binding'
              # :read !head -c4 /dev/urandom | od -A none -t x4
              networking.hostId = "f299660e";
              networking.hostName = "karl-desktop";
              boot.supportedFilesystems = [ "zfs" ];
              networking.interfaces.enp8s0.useDHCP = true;
            })
            inputs.home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              # TODO: consider moving home-manager config to nixos module - build as one
              #   home-manager.users.karl = {
              #     home.username = "karl";
              #     home.homeDirectory = "/home/karl";
              #     home.stateVersion = "21.05"; # HACK for version mismatch error
              #     # nixpkgs.overlays = overlaysCommon;
              #     # imports = importsCommon;
              #     # home.packages = with pkgs; [ discord slack ];
              #     xresources.properties = { "Xft.dpi" = "109"; };
              #     xsession.pointerCursor.size = 64;
              #   };
            }
          ];
        };

        karl-laptop = lib.nixosSystem {
          inherit system;
          modules = modulesCommon ++ [
            ./machines/hardware-configuration-karl-desktop.nix
            ({ config, ... }: {
              # Let 'nixos-version --json' know about the Git revision
              system.configurationRevision = lib.mkIf (self ? rev) self.rev;
              # Define hostId for zfs pool machine 'binding'
              # :read !head -c4 /dev/urandom | od -A none -t x4
              networking.hostId = "ff8fd5cb";
              networking.hostName = "karl-laptop";
              boot.supportedFilesystems = [ "zfs" ];
              networking.interfaces.ens33.useDHCP = true;
            })
          ];
        };

      };

    };
}
