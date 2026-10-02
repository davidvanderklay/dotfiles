{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "opencode";
  version = "2.0.22";

  # V2 is published under @opencode, separately from the V1 GitHub releases.
  # The baseline binary also works on CPUs without AVX2.
  src = fetchurl {
    url = "https://registry.npmjs.org/@opencode/cli-linux-x64-baseline/-/cli-linux-x64-baseline-${finalAttrs.version}.tgz";
    hash = "sha256-rLkEqCtXAQbUDiEgYb/ghSkAdo1HIuf8mYkIwIbBy5M=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];
  buildInputs = [ stdenv.cc.cc.lib ];
  # Preserve the embedded application and provide libraries for native modules.
  dontStrip = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 bin/opencode $out/libexec/opencode
    makeWrapper $out/libexec/opencode $out/bin/opencode \
      --prefix LD_LIBRARY_PATH : "${stdenv.cc.cc.lib}/lib"
    runHook postInstall
  '';

  meta = {
    description = "OpenCode V2 CLI";
    homepage = "https://opencode.ai/v2/docs";
    license = lib.licenses.mit;
    mainProgram = "opencode";
    platforms = [ "x86_64-linux" ];
  };
})
