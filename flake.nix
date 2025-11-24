{
  description = "Nix-managed dotfiles for macOS and the Android Debian VM";

  # Input streams (packages and flakes, not variables!)
  #
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, ... }:
  let
    # State versions for home-manager and nix-darwin as of 2025-11-23
    #
    # DO NOT UPDATE without first reading (and, if applicable, acting) on all
    # intervening release notes!
    #
    homeManagerStateVersion = "25.05";
    nixDarwinStateVersion = 6;

    # User names
    #
    myUserName = "necopinus";
    androidUserName = "droid";

    # Allow the use of "unfree" packages
    #
    nixpkgsConfig = {
      config.allowUnfree = true;
    };
  in {
    # macOS configuration (nix-darwin + home-manager)
    #
    #   sudo darwin-rebuild switch --flake .#macos
    #
    darwinConfigurations = let
      macosConfiguration = { config, pkgs, ... }: {
        system.stateVersion = nixDarwinStateVersion;
        users.users."${myUserName}" = {
          name = "${myUserName}";
          home = "/Users/${myUserName}";
        };
      };
    in {
      "macos" = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";

        modules = [
          macosConfiguration

          ./hosts/macos.nix

          home-manager.darwinModules.home-manager {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = false;

              users."${myUserName}" = {
                home.stateVersion = "${homeManagerStateVersion}";
                home.username = "${myUserName}";
                home.homeDirectory = "/Users/${myUserName}";

                modules = [
                  ./homes/common.nix
                  ./homes/macos.nix
                ];
              };
            };
          }
        ];
      };
    };

    # Non-NixOS Linux configuration (home-manager)
    #
    #   home-manager switch --flake .#android
    #
    homeConfigurations = let
      androidConfiguration = { config, pkgs, ... }: {
        home.stateVersion = "${homeManagerStateVersion}";
        home.username = "${androidUserName}";
        home.homeDirectory = "/home/${androidUserName}";
      };
    in {
      "android" = home-manager.lib.homeManagerConfiguration {
        # Looks weird, but just let's home-manager re-use the existing NixPkgs
        # definition, which is more efficient. See:
        #
        #   https://discourse.nixos.org/t/two-ways-to-write-a-home-manager-flake-is-legacypackages-needed/28109
        #
        pkgs = nixpkgs.legacyPackages.aarch64-linux;

        modules = [
          androidConfiguration

          ./homes/common.nix
          ./homes/android.nix
        ];
      };
    };
  };
}
