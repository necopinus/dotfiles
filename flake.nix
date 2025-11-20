{
  description = "Nix-managed dotfiles for macOS and the Android Debian VM";

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

  outputs = { self, nixpkgs, nix-darwin, home-manager, ... }: {
    # macOS configuration using nix-darwin
    # Bootstrap: nix run nix-darwin -- switch --flake .#MacBookPro
    # Subsequent: darwin-rebuild switch --flake .#MacBookPro
    darwinConfigurations.MacBookPro = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        ./hosts/macos.nix
        {
          system.stateVersion = 6; # Configuration state version
          users.users.necopinus = {
            name = "necopinus";
            home = "/Users/necopinus";
          };
        }
        home-manager.darwinModules.home-manager
        {
          home-manager = {
            useUserPackages = true;
            users.necopinus = {
              home.stateVersion = "25.05"; # Configuration state version
              home.username = "necopinus";
              home.homeDirectory = "/Users/necopinus";
              modules = [
                ./homes/macos.nix
              ];
            };
          };
        }
      ];
    };

    # Android Debian VM configuration using home-manager only
    # Bootstrap: nix run home-manager/master -- switch --flake .#droid@localhost
    # Subsequent: home-manager switch --flake .#droid@localhost
    homeConfigurations."droid@localhost" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.aarch64-linux;
      modules = [
        ./homes/android.nix
        {
          home.stateVersion = "25.05"; # Configuration state version
          home.username = "droid";
          home.homeDirectory = "/home/droid";
        }
      ];
    };
  };
}
