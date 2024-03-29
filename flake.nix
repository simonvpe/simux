{
  description = "A highly structured configuration database.";

  nixConfig.extra-experimental-features = "nix-command flakes ca-references";
  nixConfig.extra-substituters = "https://nrdxp.cachix.org https://nix-community.cachix.org";
  nixConfig.extra-trusted-public-keys = "nrdxp.cachix.org-1:Fc5PSqY2Jm1TrWfm88l6cvGWwz3s93c6IOifQWnhNW4= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";

  inputs =
    {
      nixos.url = "github:nixos/nixpkgs/release-22.05";
      latest.url = "github:nixos/nixpkgs/nixos-unstable";

      digga.url = "github:divnix/digga";
      digga.inputs.nixpkgs.follows = "nixos";
      digga.inputs.nixlib.follows = "nixos";
      digga.inputs.home-manager.follows = "home";

      home.url = "github:nix-community/home-manager/release-22.05";
      home.inputs.nixpkgs.follows = "nixos";

      darwin.url = "github:LnL7/nix-darwin";
      darwin.inputs.nixpkgs.follows = "latest";

      deploy.follows = "digga/deploy";

      agenix.url = "github:ryantm/agenix";
      agenix.inputs.nixpkgs.follows = "latest";

      naersk.url = "github:nmattia/naersk";
      naersk.inputs.nixpkgs.follows = "latest";

      rust-overlay.url = "github:oxalica/rust-overlay";
      rust-overlay.inputs.nixpkgs.follows = "latest";

      nixos-hardware.url = "github:simonvpe/nixos-hardware/asus-zenbook-ux371";

      # start ANTI CORRUPTION LAYER
      # remove after https://github.com/NixOS/nix/pull/4641
      nixpkgs.follows = "nixos";
      nixlib.follows = "digga/nixlib";
      blank.follows = "digga/blank";
      flake-utils-plus.follows = "digga/flake-utils-plus";
      flake-utils.follows = "digga/flake-utils-plus";
      # end ANTI CORRUPTION LAYER
    };

  outputs =
    { self
    , digga
    , nixos
    , home
    , nixos-hardware
    , nur
    , agenix
    , deploy
    , rust-overlay
    , ...
    } @ inputs:
    digga.lib.mkFlake
      {
        inherit self inputs;

        channelsConfig = { allowUnfree = true; };

        channels = rec {
          nixos = {
            imports = [ (digga.lib.importOverlays ./overlays) ];
            overlays = [
              nur.overlay
              agenix.overlay
              deploy.overlay
              rust-overlay.overlay
              ./pkgs/default.nix
            ];
          };
          latest = { };
        };

        lib = import ./lib { lib = digga.lib // nixos.lib; };

        sharedOverlays = [
          (final: prev: {
            __dontExport = true;
            lib = prev.lib.extend (lfinal: lprev: {
              our = self.lib;
            });
          })
        ];

        nixos = {
          hostDefaults = {
            system = "x86_64-linux";
            channelName = "nixos";
            imports = [ (digga.lib.importExportableModules ./modules) ];
            exportedModules = [
              { lib.our = self.lib; }
              digga.nixosModules.bootstrapIso
              digga.nixosModules.nixConfig
              home.nixosModules.home-manager
              agenix.nixosModules.age
            ];
          };

          imports = [ (digga.lib.importHosts ./hosts) ];
          hosts = {
            /* set host specific properties here */
            NixOS = { };
          };
          importables = rec {
            profiles = digga.lib.rakeLeaves ./profiles // {
              users = digga.lib.rakeLeaves ./users;
            };
            suites = with profiles; rec {
              base = [ core shell nix networking users.root ];
              laptop = base ++ [ libvirtd docker printing x11 wifi pam tpm sound users.starlord users.neti ];
              desktop = base ++ [ libvirtd printing x11 pam tpm sound users.starlord users.neti ];
            };
          };
        };

        home = {
          imports = [ (digga.lib.importExportableModules ./users/modules) ];
          exportedModules = [ ];
          importables = rec {
            profiles = digga.lib.rakeLeaves ./users/profiles;
            suites = with profiles; rec {
              base = [
                shell
                bat
                cybernet
                direnv
                exa
                skim
                git
                ssh
                surfraw
                terminal
                utils
                vim
              ];
              x11 = [
                i3
                keyboard
                polybar
                rofi
                web
              ];
              starlord = base ++ x11 ++ [ steam ./users/starlord/home.nix ];
              neti = base ++ x11 ++ [ vscode ./users/neti/home.nix ];
              simpet = base ++ x11 ++ [ ./users/simpet/home.nix ];
            };
          };
          users = {
            starlord = { suites, ... }: { imports = suites.starlord; };
            neti = { suites, ... }: { imports = suites.neti; };
            simpet = { suites, ... }: { imports = suites.simpet; };
          }; # digga.lib.importers.rakeLeaves ./users/hm;
        };

        devshell = ./shell;

        homeConfigurations = digga.lib.mkHomeConfigurations self.nixosConfigurations;

        deploy.nodes = digga.lib.mkDeployNodes self.nixosConfigurations { };
      }
  ;
}
