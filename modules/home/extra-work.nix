{ pkgs, ... }: {
  home.packages = with pkgs; [
    yarn-berry
    gdal
    kubectl
    kubelogin-oidc
    colima
  ];
}
