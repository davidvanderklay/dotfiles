{
  stdenv,
  fetchurl,
  autoPatchelfHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "t3-code-cli";
  # Keep this on the same release as the desktop package in t3code-flake.
  version = "0.0.43-nightly.20260926.2318";

  src = fetchurl {
    url = "https://github.com/pingdotgg/t3code/releases/download/v${finalAttrs.version}/t3-${finalAttrs.version}-linux-x64.tar.gz";
    hash = "sha256-Sbciq4x+FDedwHu1CPvKC4KtsYqc5HgA+Bksx3VKlKs=";
  };

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ stdenv.cc.cc.lib ];
  # Bun embeds the server bundle in the executable; stripping damages it.
  dontStrip = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp -r t3 client node_modules resource-monitor $out/bin/
    chmod +x $out/bin/t3
    runHook postInstall
  '';

  meta = {
    description = "Headless T3 Code CLI";
    homepage = "https://t3.codes";
    mainProgram = "t3";
    platforms = [ "x86_64-linux" ];
  };
})
