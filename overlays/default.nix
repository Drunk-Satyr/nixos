{
  config,
  pkgs,
  lib,
  ...
}:

{
  nixpkgs.overlays = [
    (final: prev: {
      sl = prev.sl.overrideAttrs (old: {
        src = prev.fetchFromGitHub {
          owner = "musescore";
          repo = "MuseScore";
          rev = "3224f342d12f4af8ea782e929c49f5ce85f97da6";
          # If you don't know the hash, the first time, set:
          # hash = "";
          # then nix will fail the build with such an error message:
          # hash mismatch in fixed-output derivation '/nix/store/m1ga09c0z1a6n7rj8ky3s31dpgalsn0n-source':
          # specified: sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=
          # got:    sha256-173gxk0ymiw94glyjzjizp8bv8g72gwkjhacigd1an09jshdrjb4
          hash = "";
        };
      });
    })
  ];
}
