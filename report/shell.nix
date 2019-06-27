{ pkgs ? import <nixpkgs> {} }:

with pkgs;

let
  texdeps = texlive.combine {
    inherit (texlive)
      scheme-basic koma-script babel babel-english amscls stmaryrd graphics
      mathtools keycommand hyperref oberdiek tocbibind tools footmisc xkeyval
      etoolbox pgf xcolor marginnote;
  };

in stdenvNoCC.mkDerivation {
  name = "ce-hw-report";
  buildInputs = [ rubber texdeps ];
}
