{pkgs, ...}: let
  localPkgs = {
    # Absolute path to the shared Git helper. No module import or PATH entry is
    # needed for its temporary SSH-agent and Proton Pass lifecycle management.
    ephemeralGit = pkgs.callPackage ../git/pkgs/ephemeral-git.nix {};
    backup-home = pkgs.callPackage ./pkgs/backup-home.nix {inherit (localPkgs) ephemeralGit;};
    pbcopy = pkgs.callPackage ./pkgs/pbcopy.nix {};
    pbpaste = pkgs.callPackage ./pkgs/pbpaste.nix {};
    update-system = pkgs.callPackage ./pkgs/update-system.nix {inherit (localPkgs) ephemeralGit;};
    vault-sync = pkgs.callPackage ./pkgs/vault-sync.nix {};
  };
in {
  home.packages = with pkgs;
    [
      #### Misc tools ####
      msgpack-tools
      proton-pass-cli

      #### Convenience wrappers (see above) ####
      localPkgs.backup-home
      localPkgs.pbcopy
      localPkgs.pbpaste
      localPkgs.update-system
    ]
    ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
      #### Essential utilities ####
      coreutils-full # macOS coreutils is missing some utilities; use the *-full variant to get man pages
      findutils # macOS find is missing some useful flags
      gawk
      gnupg
      xz
      yubikey-manager

      #### Convenience wrappers (see above) ####
      localPkgs.vault-sync
    ];
}
