{
  description = "hoogle test";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";

    flake-parts.url = "github:hercules-ci/flake-parts";
    haskell-nix.url = "github:input-output-hk/haskell.nix";
    herbage.url = "path:/home/sho/mlabs/herbage";
  };

  outputs = inputs@{ flake-parts, nixpkgs, haskell-nix, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      debug = true;
      systems = [ "x86_64-linux" "aarch64-darwin" "x86_64-darwin" "aarch64-linux" ];

      perSystem = { config, system, lib, self', ... }:
        let
          pkgs =
            import haskell-nix.inputs.nixpkgs {
              inherit system;
              overlays = [
                haskell-nix.overlay
                inputs.herbage.overlays.default
              ];
              inherit (haskell-nix) config;
            };

          herbage = inputs.herbage.lib { inherit pkgs; };

          hackageSetName = "foobarbaz";

          hackageKeys = pkgs.runCommand "hackageKeys" {
            buildInputs = [ pkgs.hackage-repo-tool ];
          } ''
            hackage-repo-tool create-keys --keys $out
          '';

          rootKeysRaw = pkgs.runCommand "rootKeysRaw" {
          } ''
            ls ${hackageKeys}/root > $out
          '';

          rootKeys =
            builtins.filter
              (x: builtins.isString x && x != "")
              (builtins.split "\.private\n" (builtins.readFile rootKeysRaw));

          hackage =
            herbage.genHackage
                hackageKeys
                (import ./myHaskellPackages.nix { inherit pkgs; });

          cabalProjectAddition = ''
            repository ${hackageSetName}
              url: https://foo.org
              secure: True
              root-keys:
            ${builtins.concatStringsSep "\n" (builtins.map (x: "    " + x) rootKeys)}
          '';

          projectWithLocalHackage = pkgs.runCommand "ammend-localhackage" {
            src = ./.;
          } ''
            mkdir -p $out
            touch $out/cabal.project
            cp -r $src/* $out

            echo "${cabalProjectAddition}" >> $out/cabal.project
          '';

          foo = builtins.trace cabalProjectAddition (pkgs.runCommand "a" {
          } ''
            touch $out
          '');

          project = pkgs.haskell-nix.cabalProject' {
            src = projectWithLocalHackage;
            compiler-nix-name = "ghc966";
            index-state = "2024-10-09T22:38:57Z";
            inputMap = {
              "https://foo.org" = hackage;
            };
            shell = {
              withHoogle = true;
              withHaddock = true;
              exactDeps = false;
              nativeBuildInputs = with pkgs; [
                hackage-repo-tool
              ];
            };
          };
          flake = project.flake { };

        in
        {
          inherit (flake) devShells;
          packages = flake.packages // {
            keys = hackageKeys;
            inherit rootKeys foo hackage projectWithLocalHackage;
          };

          inherit (flake) checks;
        };
    };
}
