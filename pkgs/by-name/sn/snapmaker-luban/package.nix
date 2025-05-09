{
  lib,
  stdenv,
  autoPatchelfHook,
  makeDesktopItem,
  copyDesktopItems,
  wrapGAppsHook3,
  fetchurl,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  cairo,
  cups,
  gtk3,
  nss,
  glib,
  nspr,
  gdk-pixbuf,
  libdrm,
  libgbm,
  libX11,
  libXScrnSaver,
  libXcomposite,
  libXcursor,
  libXdamage,
  libXext,
  libXfixes,
  libXi,
  libXrandr,
  libXrender,
  libXtst,
  libxcb,
  libxshmfence,
  pango,
  gcc-unwrapped,
  udev,
  python311,
}:

stdenv.mkDerivation rec {
  pname = "snapmaker-luban";
  version = "4.15.0";

  src = fetchurl {
    url = "https://github.com/Snapmaker/Luban/releases/download/v${version}/snapmaker-luban-${version}-linux-x64.tar.gz";
    hash = "sha256-X4XNzkl5ky3C8fj92J9OQxj12zmIQ+xS02wYLWo94oU=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    wrapGAppsHook3
    copyDesktopItems
  ];

  buildInputs = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    cairo
    cups
    gcc-unwrapped
    gtk3
    libdrm
    libXdamage
    libX11
    libXScrnSaver
    libXtst
    libxcb
    libxshmfence
    libgbm
    nspr
    nss
    (lib.getLib stdenv.cc.cc)
    python311
  ];

  libPath = lib.makeLibraryPath [
    stdenv.cc.cc
    alsa-lib
    atk
    at-spi2-atk
    at-spi2-core
    cairo
    cups
    gdk-pixbuf
    glib
    gtk3
    libX11
    libXcomposite
    libxshmfence
    libXcursor
    libXdamage
    libXext
    libXfixes
    libXi
    libXrandr
    libXrender
    libXtst
    nspr
    nss
    libxcb
    pango
    libXScrnSaver
    udev
  ];

  autoPatchelfIgnoreMissingDeps = [ "libc.musl-x86_64.so.1" ];

  dontWrapGApps = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,opt,share/pixmaps}/
    mv * $out/opt/

    patchelf --set-interpreter ${stdenv.cc.bintools.dynamicLinker} \
      $out/opt/snapmaker-luban

    wrapProgram $out/opt/snapmaker-luban \
      "''${gappsWrapperArgs[@]}" \
      --prefix XDG_DATA_DIRS : "${gtk3}/share/gsettings-schemas/${gtk3.name}/" \
      --prefix LD_LIBRARY_PATH : ${libPath}:$out/snapmaker-luban

    ln -s $out/opt/snapmaker-luban $out/bin/snapmaker-luban
    ln -s $out/opt/resources/app/src/app/resources/images/snapmaker-logo.png $out/share/pixmaps/snapmaker-luban.png

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = pname;
      exec = "snapmaker-luban";
      icon = "snapmaker-luban";
      desktopName = "Snapmaker Luban";
      genericName = meta.description;
      categories = [
        "Office"
        "Printing"
      ];
    })
  ];

  meta = {
    description = "Snapmaker Luban is an easy-to-use 3-in-1 software tailor-made for Snapmaker machines";
    homepage = "https://github.com/Snapmaker/Luban";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ simonkampe ];
    platforms = [ "x86_64-linux" ];
    knownVulnerabilities = [ "CVE-2023-5217" ];
  };
}
