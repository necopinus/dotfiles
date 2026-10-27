{
  lib,
  fetchFromGitHub,
  python3,
}:
python3.pkgs.buildPythonApplication {
  pname = "scimath-mcp";
  version = "0.1.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "matheusbgodoi";
    repo = "scimath-mcp";
    tag = "v0.1.1";
    hash = "sha256-Wsbj/hKImmSKbKUcQKO/9adxfweyStPEpW+OuixGebg=";
  };

  build-system = [python3.pkgs.setuptools];

  dependencies = with python3.pkgs; [
    mcp
    mpmath
    numpy
    pint
    pydantic
    scipy
    sympy
    uncertainties
  ];

  # scimath-mcp pins its own dependencies exactly in the published metadata
  # (mcp==2.0.0) and narrowly (mpmath<1.4). The pinned nixpkgs ships mcp 2.2.0
  # and mpmath 1.4.x, so relax both pins instead of vendoring older copies.
  # The pins are floors for the API scimath-mcp uses: mcp.server.mcpserver
  # arrived in mcp 2.0.0. The mpmath usage goes through sympy, which nixpkgs
  # already runs against this mpmath.
  #
  # This derivation used to vendor mcp 2.0.0 and mcp-types 2.0.0 through a
  # private python package set, because nixpkgs then shipped mcp 1.29.0 and no
  # mcp-types at all. nixpkgs now provides both, and the 25 upstream tests pass
  # against the stock packages, so the override is gone. Reintroduce it only if
  # nixpkgs drops below mcp 2.0.0 or loses mcp-types.
  pythonRelaxDeps = [
    "mpmath"
    "mcp"
  ];

  pythonImportsCheck = ["scimath_mcp"];

  nativeCheckInputs = with python3.pkgs; [pytestCheckHook];

  meta = {
    description = "Unit-aware scientific computing MCP server (SymPy, Pint, SciPy)";
    homepage = "https://github.com/matheusbgodoi/scimath-mcp";
    license = lib.licenses.mit;
    mainProgram = "scimath-mcp";
    platforms = lib.platforms.all;
  };
}
