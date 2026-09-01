{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  fetchPypi,
  python3,
}:

let
  aniparse = python3.pkgs.buildPythonPackage rec {
    pname = "aniparse";
    version = "1.2.2";
    pyproject = true;
    src = fetchPypi {
      inherit pname version;
      hash = "sha256-Zle+C9sxxiWs+FdXmNJp1vci7ikGR4H2JQE4fxtgk0w=";
    };
    build-system = [ python3.pkgs.setuptools ];
    doCheck = false;
  };

  pythonMpvJsonipc = python3.pkgs.buildPythonPackage {
    pname = "python-mpv-jsonipc";
    version = "unstable-get-input";
    pyproject = true;
    src = fetchFromGitHub {
      owner = "TnTora";
      repo = "python-mpv-jsonipc";
      rev = "get-input";
      hash = "sha256-Y+KUCyl8N4/Z7EL0CuEi8OWzl+jwvdo8di1yE9b95OI=";
    };
    build-system = [ python3.pkgs.setuptools ];
    doCheck = false;
  };

  pythonEnv = python3.withPackages (ps: [
    ps.beautifulsoup4
    ps.py7zr
    ps.requests
    aniparse
    pythonMpvJsonipc
  ]);

  src = fetchFromGitHub {
    owner = "TnTora";
    repo = "animeSubs_dl";
    rev = "87cf42b9248172fb3f7b32fb396f806c946ff69f";
    hash = "sha256-AY4+YugRz+5PX6YvHwTAZZYhVVAVv9gy6AaJhvOuWlc=";
  };
in
stdenvNoCC.mkDerivation {
  pname = "mpv-animesubs-dl";
  version = "unstable-main";

  inherit src;

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/mpv/scripts
    cp -r animeSubs_dl $out/share/mpv/scripts/animeSubs_dl

    substituteInPlace $out/share/mpv/scripts/animeSubs_dl/main.lua \
      --replace 'custom_python_cmd = nil' 'custom_python_cmd = "${pythonEnv}/bin/python3"'

    runHook postInstall
  '';

  passthru = {
    scriptName = "animeSubs_dl";
    inherit pythonEnv;
  };

  meta = with lib; {
    description = "Download Japanese subtitles for anime from jimaku or kitsunekko directly from mpv";
    homepage = "https://github.com/TnTora/animeSubs_dl";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };
}
