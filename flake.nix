{
  description = "Nix-managed dotfiles for macOS, Debian(ish) VMs (including the Android 16+ Terminal), and exe.dev";

  # Input streams (flakes, not variables!)
  #
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    nix-darwin,
    home-manager,
    ...
  }: let
    # State versions for home-manager and nix-darwin as of 2025-11-23
    #
    # DO NOT UPDATE without first reading (and, if applicable, acting) on all
    # intervening release notes!
    #
    homeManagerStateVersion = "26.05";
    nixDarwinStateVersion = 7;

    # Common home-manager modules shared by every Linux target
    #
    linuxHomeManagerCommonModules = [
      {
        nixpkgs.config.allowUnfree = true;
        home.stateVersion = "${homeManagerStateVersion}";
      }

      ./systems/common
      ./systems/linux
    ];

    # Common home-manager modules shared by the macOS target
    #
    macosHomeManagerCommonModules = [
      {
        nixpkgs.config.allowUnfree = true;
        home.stateVersion = "${homeManagerStateVersion}";
      }

      ./systems/common
      ./systems/macos
    ];

    # Linux home-manager configuration factory. Takes the architecture
    # (e.g. "aarch64-linux"), the username, and any extra module imports
    # to layer on top of the common ones.
    #
    mkLinuxHomeConfig = arch: username: extra:
      home-manager.lib.homeManagerConfiguration {
        # Looks weird, but just let's home-manager re-use the existing NixPkgs
        # definition, which is more efficient. See:
        #
        #   https://discourse.nixos.org/t/two-ways-to-write-a-home-manager-flake-is-legacypackages-needed/28109
        #
        pkgs = nixpkgs.legacyPackages.${arch};

        modules =
          [
            {
              home.username = username;
              home.homeDirectory = "/home/${username}";
            }
          ]
          ++ extra
          ++ linuxHomeManagerCommonModules;
      };
  in {
    # macOS configuration (nix-darwin + home-manager)
    #
    darwinConfigurations."macos" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";

      modules = [
        {
          nixpkgs.config.allowUnfree = true;
          system.stateVersion = nixDarwinStateVersion;
          system.primaryUser = "necopinus";
          users.users.necopinus = {
            name = "necopinus";
            home = "/Users/necopinus";
          };
        }

        ./systems/macos/nix-darwin.nix

        home-manager.darwinModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = false;

            users.necopinus = {
              home.stateVersion = "${homeManagerStateVersion}";
              home.username = "necopinus";
              home.homeDirectory = "/Users/necopinus";

              imports = macosHomeManagerCommonModules;
            };
          };
        }
      ];
    };

    # Linux home-manager configurations (one per target).
    #
    # Each call site specifies the username appropriate for that target:
    # `necopinus` for personal VMs, `exedev` for exe.dev hosts, `droid` for
    # the Android Terminal (which runs in its own VM).
    #
    homeConfigurations = {
      "android" = mkLinuxHomeConfig "aarch64-linux" "droid" [];
      "linux" = mkLinuxHomeConfig "aarch64-linux" "necopinus" [
        ./bundles/hacking
        ./bundles/opencode
      ];
      "exedev" = mkLinuxHomeConfig "x86_64-linux" "exedev" [
        ./bundles/hacking
        ./bundles/opencode
      ];
      "hermes" = mkLinuxHomeConfig "x86_64-linux" "exedev" [
        ./bundles/hermes
        ./bundles/opencode
      ];
    };
  };
}
