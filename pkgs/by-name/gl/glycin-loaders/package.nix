{ stdenv
, lib
, fetchurl
, substituteAll
, bubblewrap
, cargo
, git
, meson
, ninja
, pkg-config
, rustc
, gtk4
, cairo
, libheif
, libxml2
, gnome
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "glycin-loaders";
  version = "0.1.1";

  src = fetchurl {
    url = "mirror://gnome/sources/glycin-loaders/${lib.versions.majorMinor finalAttrs.version}/glycin-loaders-${finalAttrs.version}.tar.xz";
    hash = "sha256-J8yzAsVymOKlXu78a8vMpodj+HtIBOy40KfkXHLfuVU=";
  };

  patches = [
    (substituteAll {
      src = ./fix-paths.patch;
      bwrap = "${bubblewrap}/bin/bwrap";
    })
  ];

  nativeBuildInputs = [
    cargo
    git
    meson
    ninja
    pkg-config
    rustc
  ];

  buildInputs = [
    gtk4 # for GdkTexture
    cairo
    libheif
    libxml2 # for librsvg crate
  ];

  passthru.updateScript = gnome.updateScript {
    packageName = "glycin-loaders";
  };

  meta = with lib; {
    description = "Glycin loaders for several formats";
    homepage = "https://gitlab.gnome.org/sophie-h/glycin";
    maintainers = teams.gnome.members;
    license = with licenses; [ mpl20 /* or */ lgpl21Plus ];
    platforms = platforms.linux;
  };
})
