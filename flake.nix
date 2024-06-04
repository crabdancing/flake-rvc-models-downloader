{
  description = "A flake for building the RVC-Models-Downloader";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rvc-models-downloader-src = {
      url = "github:RVC-Project/RVC-Models-Downloader";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    rvc-models-downloader-src,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
        };
        lib = pkgs.lib;
      in {
        packages.rvc-models-downloader = pkgs.buildGoModule {
          patchPhase = ''
            sed -i 's|#!/bin/bash|#!${pkgs.bash}/bin/bash|' ./pckcfg.sh
            sed -i 's|zip|${pkgs.zip}/bin/zip|' ./pckcfg.sh
          '';
          # needed to build cfg.zip
          postConfigure = ''
            go generate
          '';
          pname = "rvc-models-downloader";
          version = "0.2.4";
          src = rvc-models-downloader-src;
          vendorHash = "sha256-V3r2MVN7wQH7OFIHhNcyx6Z5Rz3kSfSq9CyAXQJ/5MY=";
          # meta.program = '';
        };
        defaultPackage = self.packages.${system}.rvc-models-downloader;
        apps = rec {
          rvcmd = {
            type = "app";
            program = "${self.packages.${system}.rvc-models-downloader}/bin/rvcmd";
          };
          default = rvcmd;
        };
      }
    );
}
