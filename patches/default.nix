_final: _prev: {
  # For reference, this is how you do it:
  #
  #  openssh = super.openssh.overrideAttrs (oldAttrs: rec {
  #    patches =
  #      oldAttrs.patches
  #      ++ [
  #        ./openssh/openssh-9.6_p1-chaff-logic.patch
  #        ./openssh/openssh-9.6_p1-CVE-2024-6387.patch
  #      ];
  #  });
}
