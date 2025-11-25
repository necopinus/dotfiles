{
  description = "Nix-managed dotfiles for macOS and the Android Debian VM";

  # Input streams (flakes, not variables!)
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

    # Packages as flakes
    #
    systemd-lsp = {
      url = "github:JFryy/systemd-lsp";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, systemd-lsp, ... }:
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

    # Overlays to make installing packages from flakes easier
    #
    nixpkgs.overlays = [ ({
      systemd-lsp = systemd-lsp.packages.${nixpkgs.stdenv.hostPlatform.system}.default;
    }) ];
  in {
    # macOS configuration (nix-darwin + home-manager)
    #
    #   nix flake update
    #   sudo darwin-rebuild switch --flake .#macos
    #
    darwinConfigurations."macos" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";

      modules = [
        {
          system.stateVersion = nixDarwinStateVersion;
          users.users."${myUserName}" = {
            name = "${myUserName}";
            home = "/Users/${myUserName}";
          };
        }

        ./hosts/macos.nix

        home-manager.darwinModules.home-manager {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = false;

            users."${myUserName}" = {
              home.stateVersion = "${homeManagerStateVersion}";
              home.username = "${myUserName}";
              home.homeDirectory = "/Users/${myUserName}";

              imports = [
                ./homes/common.nix
                ./homes/macos.nix
              ];
            };
          };
        }
      ];
    };

    # Non-NixOS Linux configuration (home-manager)
    #
    #   nix flake update
    #   home-manager switch --flake .#android
    #
    homeConfigurations."android" = home-manager.lib.homeManagerConfiguration {
      # Looks weird, but just let's home-manager re-use the existing NixPkgs
      # definition, which is more efficient. See:
      #
      #   https://discourse.nixos.org/t/two-ways-to-write-a-home-manager-flake-is-legacypackages-needed/28109
      #
      pkgs = nixpkgs.legacyPackages.aarch64-linux;

      modules = [
        {
          home.stateVersion = "${homeManagerStateVersion}";
          home.username = "${androidUserName}";
          home.homeDirectory = "/home/${androidUserName}";
        }

        ./homes/common.nix
        ./homes/android.nix
      ];
    };
  };
}
