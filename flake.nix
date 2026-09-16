{
  description = "pqm4 dev environment: arm-none-eabi toolchain, openocd, python";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        pythonEnv = pkgs.python3.withPackages (ps: [ ps.pyserial ps.tqdm ]);
      in
      {
        devShells.default = pkgs.mkShell {
          name = "pqm4-dev";
          nativeBuildInputs = [
            pkgs.gcc-arm-embedded
            pkgs.gnumake
            pkgs.openocd
            pkgs.qemu
            pythonEnv
          ];
        };
      });
}
