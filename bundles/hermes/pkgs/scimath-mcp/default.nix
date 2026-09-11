{
  lib,
  fetchFromGitHub,
  python3,
}: let
  # scimath-mcp imports mcp.server.mcpserver, an API added in mcp 2.0.0, while
  # the pinned nixpkgs ships 1.29.0. mcp 2.0.0 also depends on mcp-types, which
  # is absent from nixpkgs. Override both inside a private python package set
  # so everything else in the profile keeps using the stock mcp.
  #
  python = python3.override {
    packageOverrides = final: prev: {
      mcp-types = prev.buildPythonPackage {
        pname = "mcp-types";
        version = "2.0.0";
        pyproject = true;
        src = final.fetchPypi {
          pname = "mcp_types";
          version = "2.0.0";
          hash = "sha256-19k5uShcmWGuiGa6de+F2jTRK6/idu+/TrahMXhtg3k=";
        };
        build-system = with final; [
          hatchling
          uv-dynamic-versioning
        ];
        dependencies = with final; [
          pydantic
          typing-extensions
        ];
        pythonImportsCheck = ["mcp_types"];
        # Not present in the sdist; upstream CI runs them from the repo.
        doCheck = false;
        meta.license = lib.licenses.asl20;
      };

      mcp = prev.mcp.overridePythonAttrs {
        version = "2.0.0";

        # The 2.0.0 GitHub source computes its dependency list dynamically; the
        # PyPI sdist has them baked into static metadata, so build from that.
        src = prev.fetchPypi {
          pname = "mcp";
          version = "2.0.0";
          hash = "sha256-D0QOc1wT7Oi7GbxizwuG9DE0SEMvu3fTXhQDT04FByg=";
        };

        postPatch = "";
        pythonRelaxDeps = [];
        doCheck = false;
        nativeCheckInputs = [];
        disabledTests = [];
        __structuredAttrs = true;

        # Dependency set for 2.0.0 per PyPI metadata: httpx and pydantic-settings
        # are gone; httpx2, mcp-types, opentelemetry-api, and typing-inspection
        # are new. cryptography satisfies the pyjwt[crypto] extra.
        dependencies = with final; [
          anyio
          cryptography
          httpx2
          jsonschema
          mcp-types
          opentelemetry-api
          pydantic
          pyjwt
          python-multipart
          sse-starlette
          starlette
          typing-extensions
          typing-inspection
          uvicorn
        ];

        optional-dependencies = {};

        pythonImportsCheck = ["mcp"];
      };
    };
  };
in
  python.pkgs.buildPythonApplication {
    pname = "scimath-mcp";
    version = "0.1.1";
    pyproject = true;

    src = fetchFromGitHub {
      owner = "matheusbgodoi";
      repo = "scimath-mcp";
      tag = "v0.1.1";
      hash = "sha256-Wsbj/hKImmSKbKUcQKO/9adxfweyStPEpW+OuixGebg=";
    };

    build-system = [python.pkgs.setuptools];

    dependencies = with python.pkgs; [
      mcp
      mpmath
      numpy
      pint
      pydantic
      scipy
      sympy
      uncertainties
    ];

    # nixpkgs ships mpmath 1.4.1; upstream pins mpmath<1.4. The usage is via
    # sympy, which nixpkgs already runs against this mpmath, so relax the pin.
    pythonRelaxDeps = ["mpmath"];

    pythonImportsCheck = ["scimath_mcp"];

    nativeCheckInputs = with python.pkgs; [pytestCheckHook];

    meta = {
      description = "Unit-aware scientific computing MCP server (SymPy, Pint, SciPy)";
      homepage = "https://github.com/matheusbgodoi/scimath-mcp";
      license = lib.licenses.mit;
      mainProgram = "scimath-mcp";
      platforms = lib.platforms.all;
    };
  }
