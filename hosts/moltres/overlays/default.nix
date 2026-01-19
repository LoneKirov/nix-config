final: prev: {
  pythonPackagesExtensions =
    prev.pythonPackagesExtensions
    ++ [
      (pythonFinal: pythonPrev: {
        podman = pythonPrev.podman.overrideAttrs (old: {
          patches = (old.patches or []) ++ [./patches/podman-py/fix-image-empty-string.patch];
        });
      })
    ];
  glances = prev.glances.overrideAttrs (old: {
    patches = (old.patches or []) ++ [./patches/glances/tests-increase-sleep.patch];
    propagatedBuildInputs = (old.propagatedBuildInputs or []) ++ [final.python3Packages.podman];
  });
}
