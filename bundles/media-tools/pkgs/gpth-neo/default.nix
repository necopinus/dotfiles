{
  lib,
  buildDartApplication,
  fetchFromGitHub,
  exiftool,
  _7zip-zstd,
  unzipNLS,
  which,
}:
buildDartApplication (finalAttrs: {
  pname = "gpth-neo";
  version = "6.4.0";

  src = fetchFromGitHub {
    owner = "Xentraxx";
    repo = "GooglePhotosTakeoutHelper_Neo";
    tag = "v${finalAttrs.version}";
    hash = "sha256-UGbTO3OOf5EsrOriSYr641uvO9Q06a6bOTYQu+5Lzl4=";
  };

  # Service initialization starts ExifTool before argument parsing. Upstream
  # returns from --help without disposing it, which keeps the process alive.
  patches = [./dispose-after-help.patch];

  # The lockfile is converted to JSON so evaluation does not require an
  # import-from-derivation step. The image package comes from a Git branch,
  # but pubspec.lock pins its commit and gitHashes pins its Nix store hash.
  pubspecLock = lib.importJSON ./pubspec.lock.json;
  gitHashes.image = "sha256-Py5JRux0xXdRpSPabwb8xrgt1835sy8Xk31ml8pL1dA=";

  # Build an ahead-of-time compiled executable. The explicit entry point
  # avoids adding an executables section to the upstream pubspec and gives
  # this fork a command name that does not collide with the original gpth.
  dartEntryPoints."bin/gpth-neo" = "bin/gpth.dart";

  # Run the correctness suites with the same external tools that the wrapped
  # executable uses. Performance benchmarks are not package build checks.
  doCheck = true;
  nativeCheckInputs = [exiftool _7zip-zstd unzipNLS which];
  checkPhase = ''
    runHook preCheck
    packageRun test test/unit test/integration test/e2e
    runHook postCheck
  '';

  # The program discovers these tools on PATH. ExifTool writes metadata, while
  # unzipNLS and 7-Zip extract Takeout archives. Unlike unzip, unzipNLS accepts
  # upstream's -O UTF-8 option. The which command performs tool discovery, and
  # buildDartApplication provides makeWrapper.
  postInstall = ''
    wrapProgram $out/bin/gpth-neo \
      --prefix PATH : ${lib.makeBinPath [exiftool _7zip-zstd unzipNLS which]}
    $out/bin/gpth-neo --help | grep -q 'GooglePhotosTakeoutHelper v${finalAttrs.version}'
  '';

  meta = {
    description = "Organize Google Photos Takeout exports and restore their metadata";
    homepage = "https://github.com/Xentraxx/GooglePhotosTakeoutHelper_Neo";
    license = lib.licenses.asl20;
    mainProgram = "gpth-neo";
    platforms = with lib.platforms; ["x86_64-linux" "aarch64-linux" "aarch64-darwin"];
  };
})
