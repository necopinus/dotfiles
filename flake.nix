{
  description = "Nix configuration for macOS and Adroid Debian VM";

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
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.necopinus = import ./homes/macos.nix;
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
      ];
    };
  };
}
