{ pkgs, unstablePkgs, ... }:
let
  nodeWithoutNpm = pkgs.runCommand "nodejs-without-npm-${pkgs.nodejs.version}" { } ''
    mkdir -p "$out/bin"
    ln -s ${pkgs.nodejs}/bin/node "$out/bin/node"
    ln -s ${pkgs.nodejs}/bin/corepack "$out/bin/corepack"
  '';
in
{
  # Base packages available on all systems
  home.packages = with pkgs; [
    # ─── Terminals and utilities ───
    zellij
    tmux
    fish
    zsh
    nushell
    which
    gawk
    perl
    coreutils
    gnused
    # ─── Window management (macOS) ───
    # yabai, skhd, and sketchybar are installed via Homebrew modules.

    # ─── Development tools ───
    volta
    carapace
    zoxide
    atuin
    jq
    bash
    starship
    fzf
    nodeWithoutNpm
    unstablePkgs.pnpm
    bun
    cargo
    go
    nil
    unstablePkgs.nixd
    unstablePkgs.neovim
    tree-sitter

    # ─── Compilers and system utilities ───
    gcc
    fd
    ripgrep
    coreutils
    unzip
    bat
    lazygit
    yazi
    television

    # ─── Nerd Fonts ───
    nerd-fonts.iosevka-term
  ];

  # Enable programs explicitly (critical for binaries to appear)
  # All program enables are centralized here
  programs.neovim.enable = false;
  programs.fish.enable = true;
  programs.nushell.enable = true;
  programs.starship.enable = false;
  programs.zsh.enable = false;  # Managed via home.file in zsh.nix
  programs.git.enable = true;
  programs.gh.enable = true;  # GitHub CLI
  programs.home-manager.enable = true;
  # Note: tmux is configured via home.file in tmux.nix, not programs.tmux

  # NOTE: home.sessionVariables removed - it generates a recursive .zshenv bug
  # XDG_CONFIG_HOME is set in shell configs instead

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
}
