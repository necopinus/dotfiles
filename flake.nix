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

    # User names
    #
    myUserName = {
      standard = "necopinus";
      android = "droid";
      exedev = "exedev";
    };

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
    # (e.g. "aarch64-linux") and any extra module imports to layer on
    # top of the common ones.
    #
    mkLinuxHomeConfig = arch: extra:
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
              home.username = "${myUserName.standard}";
              home.homeDirectory = "/home/${myUserName.standard}";
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
          system.primaryUser = "${myUserName.standard}";
          users.users."${myUserName.standard}" = {
            name = "${myUserName.standard}";
            home = "/Users/${myUserName.standard}";
          };
        }

        ./systems/macos/nix-darwin.nix

        home-manager.darwinModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = false;

            users."${myUserName.standard}" = {
              home.stateVersion = "${homeManagerStateVersion}";
              home.username = "${myUserName.standard}";
              home.homeDirectory = "/Users/${myUserName.standard}";

              imports = macosHomeManagerCommonModules;
            };
          };
        }
      ];
    };

    # Android 16+ Linux Terminal configuration (home-manager)
    #
    homeConfigurations."android" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.aarch64-linux;

      modules =
        [
          {
            home.username = "${myUserName.android}";
            home.homeDirectory = "/home/${myUserName.android}";
          }
        ]
        ++ linuxHomeManagerCommonModules;
    };

    # Generic (isolated) Linux VM configuration (home-manager)
    #
    homeConfigurations."linux" = mkLinuxHomeConfig "aarch64-linux" [
      ./bundles/hacking
      ./bundles/opencode
    ];

    # Generic exe.dev configuration (home-manager)
    #
    homeConfigurations."exedev" = mkLinuxHomeConfig "x86_64-linux" [
      ./bundles/hacking
      ./bundles/opencode
    ];

    # Hermes (exe.dev) server configuration (home-manager)
    #
    homeConfigurations."hermes" = mkLinuxHomeConfig "x86_64-linux" [
      ./bundles/hermes
      ./bundles/opencode
    ];
  };
}
