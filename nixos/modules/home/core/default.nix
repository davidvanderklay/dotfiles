{
  config,
  pkgs,
  lib,
  ...
}:
{
  # Essential CLI tools for every user session
  home.packages = with pkgs; [
    btop
    jq
    ripgrep
    fd
    unzip
    zip
  ];

  # Shared Environment Variables
  home.sessionVariables = {
    EDITOR = "nvim";
  };

  # Generic Home Manager requirements
  programs.home-manager.enable = true;
}
