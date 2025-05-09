{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
  curl,
  sqlite,
}:

rustPlatform.buildRustPackage rec {
  pname = "nix-index";
  version = "0.1.8";

  src = fetchFromGitHub {
    owner = "nix-community";
    repo = "nix-index";
    rev = "v${version}";
    hash = "sha256-r3Vg9ox953HdUp5Csxd2DYUyBe9u61fmA94PpcAZRqo=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-BKVxtd+gbCHzpnr5LZmKMUMEEZvsZMT0AdlfrLpMYpc=";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [
    openssl
    curl
    sqlite
  ];

  postInstall = ''
    substituteInPlace command-not-found.sh \
      --subst-var out
    install -Dm555 command-not-found.sh -t $out/etc/profile.d
  '';

  meta = with lib; {
    description = "Files database for nixpkgs";
    homepage = "https://github.com/nix-community/nix-index";
    changelog = "https://github.com/nix-community/nix-index/blob/${src.rev}/CHANGELOG.md";
    license = with licenses; [ bsd3 ];
    maintainers = with maintainers; [
      bennofs
      figsoda
      ncfavier
    ];
  };
}
