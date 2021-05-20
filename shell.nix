let

  sources = import ./nix/sources.nix;
  pkgs = import sources.nixpkgs {};

in

  pkgs.mkShell {
    buildInputs = [

      # Dev Tools
      pkgs.devd
      pkgs.just
      pkgs.watchexec

      # Language Specific
      pkgs.elmPackages.elm
      pkgs.nodePackages.pnpm

    ];
  }
