{pkgs, ...}: let
  localPkgs = {
    # Absolute path to the shared helpers. No module import or PATH entry is
    # needed for its temporary SSH-agent and Proton Pass lifecycle management.
    ephemeral-git = pkgs.callPackage ../../bundles/git/pkgs/ephemeral-git.nix {};
    gpth-neo = pkgs.callPackage ./pkgs/gpth-neo {};

    backup-home = pkgs.callPackage ./pkgs/backup-home.nix {inherit (localPkgs) ephemeral-git;};
    pbcopy = pkgs.callPackage ./pkgs/pbcopy.nix {};
    pbpaste = pkgs.callPackage ./pkgs/pbpaste.nix {};
    update-system = pkgs.callPackage ./pkgs/update-system.nix {inherit (localPkgs) ephemeral-git;};
    vault-sync = pkgs.callPackage ./pkgs/vault-sync.nix {inherit (localPkgs) ephemeral-git gpth-neo;};
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
