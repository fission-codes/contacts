{ rosetta ? false }:
let
  overrides = if rosetta then { system = "x86_64-darwin"; } else {};

  sources = import ./nix/sources.nix;
  pkgs = import sources.nixpkgs overrides;

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
