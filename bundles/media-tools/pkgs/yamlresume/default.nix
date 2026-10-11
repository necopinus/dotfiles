{
  lib,
  buildNpmPackage,
  fetchurl,
  makeFontsConf,
  makeWrapper,
  fontconfig,
  libertine,
  noto-fonts-cjk-sans-static,
  noto-fonts-cjk-serif-static,
  texliveSmall,
}: let
  # TeX environment for PDF output. yamlresume shells out to xelatex
  # (tectonic is only probed as a fallback), and scheme-small covers the
  # common packages (fontspec, geometry, hyperref, ...). The extras are
  # the moderncv class, the jake template's latex-extra packages, ctex
  # for CJK resumes, both fontawesome versions the templates probe for,
  # and the babel packs for every non-English locale yamlresume supports
  # (es, fr, nb, nl, de, id, pt-BR). Dependencies between TeX packages
  # resolve automatically here.
  texlive = texliveSmall.withPackages (
    ps: [
      ps.moderncv
      ps.changepage
      ps.enumitem
      ps.titlesec
      ps.ctex
      ps.fontawesome5
      ps.fontawesome7
      ps.babel-spanish
      ps.babel-french
      ps.babel-norsk
      ps.babel-dutch
      ps.babel-german
      ps.babel-indonesian
      ps.babel-portuges
    ]
  );

  # Fonts the LaTeX renderer probes for by name (\IfFontExistsTF): Linux
  # Libertine O as the main font, Noto Serif/Sans CJK SC for CJK resumes.
  # The static Noto CJK packages are required: the variable-font TTCs in
  # noto-fonts-cjk-{sans,serif} make xdvipdfmx fail with "Invalid TTC
  # index number" when embedding them. makeFontsConf extends the stock
  # fontconfig config with these store paths while keeping the host's
  # font directories visible, so resumes using other installed fonts
  # still render.
  fontsConf = makeFontsConf {
    fontDirectories = [
      libertine
      noto-fonts-cjk-sans-static
      noto-fonts-cjk-serif-static
    ];
  };
in
  buildNpmPackage {
    pname = "yamlresume";
    version = "0.17.0";

    # The npm registry tarball ships a prebuilt dist/, which avoids
    # vendoring the upstream pnpm monorepo (cli + 4 workspace deps).
    src = fetchurl {
      url = "https://registry.npmjs.org/yamlresume/-/yamlresume-0.17.0.tgz";
      hash = "sha256-Es92EOHeGE9ujmA2PB976NiUtdXJ80XAH2Jil/9nVMk=";
    };

    # The tarball has no lockfile, and its devDependencies reference the
    # unpublished workspace package @yamlresume/testing. Both vendored
    # files are generated from the tarball's manifest with devDependencies
    # and scripts removed (dist/ is prebuilt, so neither is used); see
    # check-updates.sh for the regeneration steps.
    postPatch = ''
      cp ${./package.json} package.json
      cp ${./package-lock.json} package-lock.json
    '';

    npmDepsHash = "sha256-29YmsZsl8zKTFBkHhmcAlWG5+yPDERbgzLt9VV0ygu8=";

    dontNpmBuild = true;

    nativeBuildInputs = [makeWrapper];

    # Fold the runtime environment into the wrapper so the binary is
    # self-contained: xelatex + fc-list on PATH, and a fontconfig file
    # that makes the required fonts resolvable. HTML, Markdown, and DOCX
    # output are pure JavaScript and need nothing extra.
    postInstall = ''
      wrapProgram $out/bin/yamlresume \
        --prefix PATH : ${lib.makeBinPath [texlive fontconfig]} \
        --set FONTCONFIG_FILE ${fontsConf}
    '';

    meta = {
      description = "Resumes as code in YAML";
      homepage = "https://yamlresume.dev";
      license = lib.licenses.mit;
      mainProgram = "yamlresume";
      platforms = lib.platforms.all;
    };
  }
