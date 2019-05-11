{ pkgs ? import <nixpkgs> {} }:

with pkgs;

let
  ghdlpkgs = import (fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "b249f7f1a81765321d65c1f7861598ee4a5020a6";
    sha256 = "0ys3wx291a2j7k6j5wa0i10gz1ywkkl9zzf534glrhhn7frvi39z";
  }) {};

in stdenv.mkDerivation {
  name = "hw-assignment";
  buildInputs = [ ghdlpkgs.ghdl_llvm gtkwave zlib ];
}
