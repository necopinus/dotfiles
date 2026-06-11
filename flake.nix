{
  description = "Nix-managed dotfiles for macOS, Debian(ish) VMs (including the Android 16+ Terminal), and exe.dev";

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
    myUserName = {
      standard = "necopinus";
      android = "droid";
      exedev = "exedev";
    };

    # Home Manager modules/imports
    #
    linuxHomeManagerCommonModules = [
      {
        nixpkgs.config.allowUnfree = true;
        home.stateVersion = "${homeManagerStateVersion}";
      }

      ./hosts/linux.nix
      ./homes/common.nix
      ./homes/linux.nix
    ];
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

        ./hosts/macos.nix

        home-manager.darwinModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = false;
            extraSpecialArgs = {inherit llm-agents;};

            users."${myUserName}" = {
              home.stateVersion = "${homeManagerStateVersion}";
              home.username = "${myUserName.standard}";
              home.homeDirectory = "/Users/${myUserName.standard}";

              imports = [
                ./homes/common.nix
                ./homes/macos.nix
                ./programs/claude.nix
              ];
            };
          };
        }
      ];
    };

    # Android 16+ Linux Terminal configuration (home-manager)
    #
    homeConfigurations."android" = home-manager.lib.homeManagerConfiguration {
      # Looks weird, but just let's home-manager re-use the existing NixPkgs
      # definition, which is more efficient. See:
      #
      #   https://discourse.nixos.org/t/two-ways-to-write-a-home-manager-flake-is-legacypackages-needed/28109
      #
      pkgs = nixpkgs.legacyPackages.aarch64-linux;
      extraSpecialArgs = {inherit llm-agents;};

      modules =
        [
          {
            home.username = "${myUserName.android}";
            home.homeDirectory = "/home/${myUserName.android}";
          }
        ]
        ++ linuxHomeManagerCommonModules;
    };

    # Isolated Linux VM configuration (home-manager)
    #
    homeConfigurations."linux" = home-manager.lib.homeManagerConfiguration {
      # Looks weird, but just let's home-manager re-use the existing NixPkgs
      # definition, which is more efficient. See:
      #
      #   https://discourse.nixos.org/t/two-ways-to-write-a-home-manager-flake-is-legacypackages-needed/28109
      #
      pkgs = nixpkgs.legacyPackages.aarch64-linux;
      extraSpecialArgs = {inherit llm-agents;};

      modules =
        [
          {
            home.username = "${myUserName.standard}";
            home.homeDirectory = "/home/${myUserName.standard}";
          }

          ./programs/claude.nix
          ./programs/hacking.nix
        ]
        ++ linuxHomeManagerCommonModules;
    };

    # exedev configuration (home-manager)
    #
    homeConfigurations."exedev" = home-manager.lib.homeManagerConfiguration {
      # Looks weird, but just let's home-manager re-use the existing NixPkgs
      # definition, which is more efficient. See:
      #
      #   https://discourse.nixos.org/t/two-ways-to-write-a-home-manager-flake-is-legacypackages-needed/28109
      #
      pkgs = nixpkgs.legacyPackages.aarch64-linux;
      extraSpecialArgs = {inherit llm-agents;};

      modules =
        [
          {
            home.username = "${myUserName.exedev}";
            home.homeDirectory = "/home/${myUserName.exedev}";
          }

          ./programs/claude.nix
          ./programs/hacking.nix
        ]
        ++ linuxHomeManagerCommonModules;
    };
  };
}
