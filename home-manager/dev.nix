{ config, pkgs, ... }:

# laptop not server

{
  home.packages = with pkgs; [
    # dev
    bats
    go-jsonnet
    jsonnet-bundler
    openssl
    rnix-lsp
    shellcheck
    shfmt
    terraform # terraform_0_12

    # clouds
    awscli2

    # kubernetes
    kind
    kubectl
    kubectx
    kubeval
    stern
  ];

  programs.go = { enable = true; };

}
