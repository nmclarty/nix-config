{ flake, ... }: {
  imports = with flake.modules.home; [
    default
    extra-devel
  ];
}
