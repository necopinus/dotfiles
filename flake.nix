{
  description = "Nix-managed dotfiles for macOS and Debian VMs";

  # Numtide binary cache for AI-related tools
  #
  #   https://github.com/numtide/llm-agents.nix?tab=readme-ov-file#binary-cache
  #
  nixConfig = {
    extra-substituters = ["https://cache.numtide.com"];
    extra-trusted-public-keys = ["niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="];
  };

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

    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    nix-darwin,
    home-manager,
    llm-agents,
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
    vmUserName = "droid"; # Not configurable on Android, so just use it everywhere
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
            extraSpecialArgs = {inherit llm-agents;};

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

    # Debian VM configuration (home-manager)
    #
    homeConfigurations."debian" = home-manager.lib.homeManagerConfiguration {
      # Looks weird, but just let's home-manager re-use the existing NixPkgs
      # definition, which is more efficient. See:
      #
      #   https://discourse.nixos.org/t/two-ways-to-write-a-home-manager-flake-is-legacypackages-needed/28109
      #
      pkgs = nixpkgs.legacyPackages.aarch64-linux;
      extraSpecialArgs = {inherit llm-agents;};

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
          home.username = "${vmUserName}";
          home.homeDirectory = "/home/${vmUserName}";
        }

        ./hosts/debian.nix
        ./homes/common.nix
        ./homes/debian.nix
      ];
    };
  };
}
