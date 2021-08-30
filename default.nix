{ nixpkgs ? <nixpkgs>
, nixos-config ? ./configuration.nix, system }:

{
  #inherit ({
    # this is actually the default so can be omitted.
    # configuration = <nixos-config>;
  #}) system;
}
