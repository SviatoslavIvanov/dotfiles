{ pkgs, ... }:

let
  # Homebrew 6 refuses to load formulae, casks and commands from third-party
  # taps until they are trusted, and a single untrusted entry aborts the whole
  # `brew bundle` — which takes the rest of the activation down with it.
  #
  # Trust is granted per entry rather than per tap on purpose: `brew trust
  # <tap>` would also cover whatever that tap adds later, which is exactly the
  # blanket permission the gate exists to prevent.
  #
  # Keep in sync with the brews/casks lists in darwin.nix. Names are spelled
  # the way `brew trust` normalises them, which is lower case — darwin.nix
  # writes FelixKratz/formulae/borders, brew stores felixkratz/formulae/borders.
  declared = {
    trustedformulae = [ "felixkratz/formulae/borders" ];
  };
  declaredFile = pkgs.writeText "homebrew-trust-declared.json" (builtins.toJSON declared);
in
{
  # Note: home-manager activation runs after nix-darwin has already invoked
  # brew bundle, so on a machine that has never had this file the first switch
  # still fails on the untrusted tap and the second one succeeds.
  home.activation.homebrewTrust = ''
    TRUST="''${XDG_CONFIG_HOME:-$HOME/.config}/homebrew/trust.json"
    mkdir -p "$(dirname "$TRUST")"
    [ ! -f "$TRUST" ] && echo '{}' > "$TRUST"

    # Union rather than overwrite: everything declared above is guaranteed to
    # be present, and entries added by hand with `brew trust` are preserved.
    tmpfile=$(mktemp)
    ${pkgs.jq}/bin/jq --slurpfile declared ${declaredFile} '
      reduce ($declared[0] | keys_unsorted[]) as $key
        (.; .[$key] = (((.[$key] // []) + $declared[0][$key]) | unique))
    ' "$TRUST" > "$tmpfile" && mv "$tmpfile" "$TRUST"
    chmod 600 "$TRUST"
  '';
}
