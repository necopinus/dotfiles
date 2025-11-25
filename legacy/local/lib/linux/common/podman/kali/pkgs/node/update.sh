#!/usr/bin/env bash

nix-shell -p nodePackages.node2nix --command "node2nix -i node-pkgs.json -o node-pkgs.nix"
