{
  config,
  pkgs,
  ...
}: let
  vscode-with-ext = pkgs.vscode-with-extensions.override {
    vscodeExtensions = with pkgs.vscode-extensions;
      [
        tamasfe.even-better-toml
        ms-vscode.cpptools
        vadimcn.vscode-lldb
        mikestead.dotenv
        golang.go
        hashicorp.terraform
        #visualstudioexptteam.vscodeintellicode
        #julialang.language-julia
        redhat.java
        james-yu.latex-workshop
        ms-vsliveshare.vsliveshare
        bbenoist.nix
        mkhl.direnv
        #4ops.packer
        ms-python.vscode-pylance
        ms-python.python
        matklad.rust-analyzer
        bradlc.vscode-tailwindcss
        asvetliakov.vscode-neovim
        vscodevim.vim
        zxh404.vscode-proto3
        redhat.vscode-yaml
        maximedenes.vscoq
        streetsidesoftware.code-spell-checker
        #ocamllabs.ocaml-platform #disabled
        ms-toolsai.jupyter
        github.copilot
      ]
      ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          name = "gitblame";
          publisher = "waderyan";
          version = "11.0.1";
          sha256 = "icJ0mvP8mJVO/n2M3xlCIoUdSy3MSbk3Z+B320VxOYU=";
        }
        {
          name = "d2";
          publisher = "terrastruct";
          version = "0.8.8";
          sha256 = "nnljLG2VL7r8bu+xFOTBx5J2UBsdjOwtAzDDXKtK0os=";
        }
      ];
  };
in {
  environment.systemPackages = with pkgs; [
    # Editors
    vscode-with-ext
    #jetbrains.idea-ultimate
    #zed
    #helix
    #lapce

    # Tools
    d2
    scc
    pmd
    hyperfine
    hexedit
    colordiff
    delta
    man-pages
    man-pages-posix
    rr
    gdb
    lldb
    llvmPackages_18.libllvm # ensure llvm-symbolizer is on PATH, lldb needs it
    binutils
    ltrace
    valgrind
    massif-visualizer
    gnumake
    parallel
    jq
    bc
    dialog
    picocom
    mmv
    shellcheck
    traceroute
    dig
    whois

    # Language-specific stuff
    rustup
    mold # fast linker
    cargo-edit
    cargo-update
    cargo-expand
    cargo-generate
    diesel-cli
    sqlx-cli

    gcc
    clang_18
    clang-tools

    go
    delve
    gotestsum
    gotools
    golangci-lint
    mockgen

    protobuf
    protoc-gen-go
    protoc-gen-go-grpc

    nodejs_22
    nodePackages_latest.yarn

    (python311.withPackages (ps: [
      ps.seaborn
      ps.pandas
      ps.numpy
      ps.jupyter
      (ps.buildPythonPackage rec {
        pname = "jupyterlab-vim";
        version = "4.1.3";
        pyproject = true;
        src = pkgs.fetchPypi {
          pname = "jupyterlab_vim";
          inherit version;
          hash = "sha256-V+GgpO3dIzTo16fA34D1CXt49UgP+oQwfy5QjfmLaHg=";
        };
        buildInputs = [pkgs.python311Packages.hatchling pkgs.python311Packages.hatch-nodejs-version pkgs.python311Packages.hatch-jupyter-builder];
        propagatedBuildInputs = [pkgs.python311Packages.jupyterlab];
      })
    ]))
    python311Packages.pip
    python311Packages.virtualenv

    jdk
    maven

    arduino
    arduino-cli
    avrdude

    ansible
    ansible-lint

    #terraform

    kubectl

    #vagrant

    #packer

    flyctl
    fly
  ];

  programs.adb.enable = true;

  documentation.dev.enable = true;

  # rr-zen_workaround causes trouble with suspend, so we don't enable it by default
  boot.extraModulePackages = [config.boot.kernelPackages.rr-zen_workaround];
}
