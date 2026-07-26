/*
https://github.com/Bad3r/nixos/issues/408
https://github.com/NixOS/nixpkgs/pull/545267

pandas-stubs is a transitive pytest check-input (openai, pandera, pdfplumber,
meshtastic, ...). Its test suite sets `filterwarnings = error`, so under
pytest 9.1+ the collection-time PytestRemovedIn10Warning raised for the
non-Collection iterable passed to `@pytest.mark.parametrize` in
tests/arrays/*.py turns into 8 collection errors that abort the build.

Append `-W ignore::pytest.PytestRemovedIn10Warning` to `pytestFlags`, so
the warning is ignored at collection time. The resulting drv hash matches
the one Bad3r/nixos#408 reports as the known-good build (3.0.3.260530,
3151 tests pass).

We can't simply swap `pytestCheckHook` for `pytest9_0CheckHook` via
`overrideAttrs`: the upstream package expression captures the
`pytestCheckHook` argument by value when building `nativeCheckInputs`,
and `nativeCheckInputs` is consumed by `mk-python-derivation.nix` and
folded into the build env inside `mkDerivation`, so a post-hoc attribute
override has no effect on the actual pytest version propagated to the
build environment. The more targeted nixpkgs#545267 approach (which does
this swap at the source level) can replace this overlay once it lands
in our nixpkgs input.

pythonPackagesExtensions applies to every interpreter set, so the override
follows the default `python3` interpreter wherever it lands.
*/
{
  nixpkgs.overlays = [
    (_final: prev: {
      pythonPackagesExtensions =
        prev.pythonPackagesExtensions
        ++ [
          (_pyfinal: pyprev: {
            pandas-stubs = pyprev.pandas-stubs.overrideAttrs (old: {
              pytestFlags =
                (old.pytestFlags or [])
                ++ [
                  "-W"
                  "ignore::pytest.PytestRemovedIn10Warning"
                ];
            });
          })
        ];
    })
  ];
}
