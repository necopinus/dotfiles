{
  description = "Nix-managed dotfiles for macOS and the Android Debian VM";

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
    homeManagerStateVersion = "25.11";
    nixDarwinStateVersion = 6;

    # User names
    #
    myUserName = "necopinus";
    androidUserName = "droid";
  in {
    # macOS configuration (nix-darwin + home-manager)
    #
    darwinConfigurations."macos" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";

      modules = [
        # Allow "unfree" packages; needs to be set here rather than in
        # the global let statement above... for reasons?
        #
        # I honestly don't get why NixPkgs overlays and config
        # directives go in different places...
        #
        {nixpkgs.config.allowUnfree = true;}

        {
          system.stateVersion = nixDarwinStateVersion;
          system.primaryUser = "${myUserName}";
          users.users."${myUserName}" = {
            name = "${myUserName}";
            home = "/Users/${myUserName}";
          };
        }

        ./hosts/macos.nix

        home-manager.darwinModules.home-manager
        {
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
    homeConfigurations."android" = home-manager.lib.homeManagerConfiguration {
      # Looks weird, but just let's home-manager re-use the existing NixPkgs
      # definition, which is more efficient. See:
      #
      #   https://discourse.nixos.org/t/two-ways-to-write-a-home-manager-flake-is-legacypackages-needed/28109
      #
      pkgs = nixpkgs.legacyPackages.aarch64-linux;

      modules = [
        # Allow "unfree" packages; needs to be set here rather than in
        # the global let statement above... for reasons?
        #
        # I honestly don't get why NixPkgs overlays and config
        # directives go in different places...
        #
        {nixpkgs.config.allowUnfree = true;}

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
