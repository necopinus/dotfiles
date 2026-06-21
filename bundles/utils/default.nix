{pkgs, ...}: let
  localPkgs = {
    backup-home = pkgs.callPackage ./pkgs/backup-home.nix {};
    editor = pkgs.callPackage ./pkgs/editor.nix {};
    nvim = pkgs.callPackage ./pkgs/nvim.nix {};
    pbcopy = pkgs.callPackage ./pkgs/pbcopy.nix {};
    pbpaste = pkgs.callPackage ./pkgs/pbpaste.nix {};
    shutdown = pkgs.callPackage ./pkgs/shutdown.nix {};
    sudo = pkgs.callPackage ./pkgs/sudo.nix {};
    update-system = pkgs.callPackage ./pkgs/update-system.nix {};
    vault-sync = pkgs.callPackage ./pkgs/vault-sync.nix {};
    vi = pkgs.callPackage ./pkgs/vi.nix {};
    vim = pkgs.callPackage ./pkgs/vim.nix {};
  };
in {
  home.packages = with pkgs;
    [
      #### Convenience wrappers (see above) ####
      localPkgs.backup-home
      localPkgs.editor
      localPkgs.nvim
      localPkgs.pbcopy
      localPkgs.pbpaste
      localPkgs.shutdown
      localPkgs.sudo
      localPkgs.update-system
      localPkgs.vi
      localPkgs.vim
    ]
    ++ lib.optionals pkgs.stdenv.isDarwin [
      #### Essential utilities ####
      coreutils-full # macOS coreutils is missing some utilities; use the *-full variant to get man pages
      findutils # macOS find is missing some useful flags
      gawk
      xz

      #### Convenience wrappers (see above) ####
      localPkgs.vault-sync
    ];
}
