{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, sqlite
, zstd
, stdenv
, darwin
, fetchurl
}:

let
  apexcharts = fetchurl {
    url = "https://cdn.jsdelivr.net/npm/apexcharts@3.47.0/dist/apexcharts.min.js";
    sha256 = "sha256-StFDdV+DR9yItbCXAGTK6EUcu613N3vM0i5ngrYZlz4=";
  };
  tablerCss = fetchurl {
    url = "https://cdn.jsdelivr.net/npm/@tabler/core@1.0.0-beta20/dist/css/tabler.min.css";
    sha256 = "sha256-lS3nKxMMZiKIRJG7UgUonOHYuvHgW5eckEjvHMYxb9Q=";
  };
  tablerVendorsCss = fetchurl {
    url = "https://cdn.jsdelivr.net/npm/@tabler/core@1.0.0-beta20/dist/css/tabler-vendors.min.css";
    sha256 = "sha256-Aa7AUOaz6hJLiUzQStZTy2VPOZyg0ViSo2MCzpDU1tY=";
  };
  tablerJs = fetchurl {
    url = "https://cdn.jsdelivr.net/npm/@tabler/core@1.0.0-beta20/dist/js/tabler.min.js";
    sha256 = "sha256-ygO5OTRUtYxDDkERRwBCfq+fmakhM6ybwfl6gCCPlAQ=";
  };
  listJsFixed = fetchurl {
    url = "https://cdn.jsdelivr.net/npm/list.js-fixed@2.3.4/dist/list.min.js";
    sha256 = "sha256-sYy7qNJW7RTuaNA0jq6Yrtfs57ypYrItZ3f8T7kqfPM=";
  };
  tablerIcons = fetchurl {
    url = "https://cdn.jsdelivr.net/npm/@tabler/icons-sprite@3.2.0/dist/tabler-sprite.svg";
    sha256 = "sha256-/5EZGfY2dZE9x8+QELgShF2EkAu6fENdlTO8Sm3hyNI=";
  };
  tomselect = fetchurl {
    url = "https://cdn.jsdelivr.net/npm/tom-select@2.3.1/dist/js/tom-select.popular.min.js";
    sha256 = "sha256-51NcdIM8GseVFFmg8mUWDxfhjLCA+n8kw/Ojyo+6Hjk=";
  };
in

rustPlatform.buildRustPackage rec {
  pname = "sqlpage";
  version = "0.20.5";

  src = fetchFromGitHub {
    owner = "lovasoa";
    repo = "SQLpage";
    rev = "v${version}";
    sha256 = "sha256-Bjjiy+KV2dIS4vNuUmUgpIFCOAVQ5LdE9QEI443Qn5I=";
    };

  postPatch = ''
    substituteInPlace sqlpage/apexcharts.js \
      --replace '/* !include https://cdn.jsdelivr.net/npm/apexcharts@3.47.0/dist/apexcharts.min.js */' \
      "$(cat ${apexcharts})"
    substituteInPlace sqlpage/sqlpage.css \
      --replace '/* !include https://cdn.jsdelivr.net/npm/@tabler/core@1.0.0-beta20/dist/css/tabler.min.css */' \
      "$(cat ${tablerCss})"
    substituteInPlace sqlpage/sqlpage.css \
      --replace '/* !include https://cdn.jsdelivr.net/npm/@tabler/core@1.0.0-beta20/dist/css/tabler-vendors.min.css */' \
      "$(cat ${tablerVendorsCss})"
    substituteInPlace sqlpage/sqlpage.js \
      --replace '/* !include https://cdn.jsdelivr.net/npm/@tabler/core@1.0.0-beta20/dist/js/tabler.min.js */' \
      "$(cat ${tablerJs})"
    substituteInPlace sqlpage/sqlpage.js \
      --replace '/* !include https://cdn.jsdelivr.net/npm/list.js-fixed@2.3.4/dist/list.min.js */' \
      "$(cat ${listJsFixed})"
    substituteInPlace sqlpage/tabler-icons.svg \
      --replace '/* !include https://cdn.jsdelivr.net/npm/@tabler/icons-sprite@3.2.0/dist/tabler-sprite.svg */' \
      "$(cat ${tablerIcons})"
    substituteInPlace sqlpage/tomselect.js \
      --replace '/* !include https://cdn.jsdelivr.net/npm/tom-select@2.3.1/dist/js/tom-select.popular.min.js */' \
      "$(cat ${tomselect})"
    '';
  
  cargoHash = "sha256-Ien2a18jo5QkazdQPq1XdAIrJic7PWfxiF40QHLpUFM=";
  
  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs =
    [
      sqlite
      zstd
    ]
    ++ lib.optionals stdenv.isDarwin [
      darwin.apple_sdk.frameworks.CoreFoundation
      darwin.apple_sdk.frameworks.Security
      darwin.apple_sdk.frameworks.SystemConfiguration
    ];

  env = {
    ZSTD_SYS_USE_PKG_CONFIG = true;
  };

  meta = {
    description = "SQL-only webapp builder, empowering data analysts to build websites and applications quickly";
    homepage = "https://github.com/lovasoa/SQLpage";
    changelog = "https://github.com/lovasoa/SQLpage/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dit7ya ];
    mainProgram = "sqlpage";
  };
}