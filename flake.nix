{
  description = "Gentleman: Single config for all systems in one go";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";  # Home Manager repository
      inputs.nixpkgs.follows = "nixpkgs";  # Follow nixpkgs input
    };
    flake-utils.url = "github:numtide/flake-utils";  # Flake utilities
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, flake-utils, ... }:
    let
      # Support macOS systems only
      supportedSystems = [ "x86_64-darwin" "aarch64-darwin" ];

      # ─── Library: reusable Home Manager modules ───────────────────────────
      # Consumers import homeModules.default (full stack) or individual modules
      # (homeModules.<name>) via extraSpecialArgs = { inherit unstablePkgs; }.
      # personal.nix is intentionally excluded from default — identity is opt-in.
      homeModules = rec {
        # Aggregate module: wraps all tool modules as { imports = [...]; }.
        # Consumers use: imports = [ gentleman.homeModules.default ];
        # Excludes personal.nix so consumers own home.username / homeDirectory.
        default = {
          imports = [
            ./nushell.nix
            ./ghostty.nix
            ./alacritty.nix
            ./zed.nix
            ./television.nix
            ./wezterm.nix
            ./kitty.nix
            ./zellij.nix
            ./tmux.nix
            ./tmux-agents.nix
            ./fish.nix
            ./nvim.nix
            ./zsh.nix
            ./oil-scripts.nix
            ./opencode.nix
            ./claude.nix
            ./engram.nix
            ./herdr.nix
            ./nehir.nix
            ./raycast.nix
            ./base-packages.nix
          ];
        };

        # Per-module attrs — downstream flakes can pick individual modules.
        alacritty    = ./alacritty.nix;
        base-packages = ./base-packages.nix;
        claude       = ./claude.nix;
        engram       = ./engram.nix;
        fish         = ./fish.nix;
        ghostty      = ./ghostty.nix;
        herdr        = ./herdr.nix;
        kitty        = ./kitty.nix;
        nehir        = ./nehir.nix;
        nushell      = ./nushell.nix;
        nvim         = ./nvim.nix;
        oil-scripts  = ./oil-scripts.nix;
        opencode     = ./opencode.nix;
        raycast      = ./raycast.nix;
        television   = ./television.nix;
        tmux         = ./tmux.nix;
        tmux-agents  = ./tmux-agents.nix;
        wezterm      = ./wezterm.nix;
        zed          = ./zed.nix;
        zellij       = ./zellij.nix;
        zsh          = ./zsh.nix;

        # Identity module: opt-in only — NOT in default.
        # Exposes home.username / homeDirectory for Gentleman's own activation.
        personal     = ./personal.nix;

        # Work-only layer. It inherits the shared personal workflow, including
        # Nehir, and adds settings that belong only on the work Mac.
        work = {
          imports = [
            default
            ./modules/work.nix
          ];
        };
      };

      # Function to create home configuration for a specific system
      mkHomeConfiguration = system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          unstablePkgs = import nixpkgs-unstable {
            inherit system;
            config.allowUnfree = true;
          };
        in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          # Pass extraSpecialArgs to make unstablePkgs available in modules
          extraSpecialArgs = {
            inherit unstablePkgs;
          };

          modules = [
            homeModules.work     # Shared workflow plus the work-only layer.
            ./personal.nix       # Identity: home.username / homeDirectory (Gentleman-specific)
            { home.stateVersion = "24.11"; }
          ];
        };
    in
    {
      # ─── Library outputs ─────────────────────────────────────────────────
      # Downstream flakes (e.g. estebandiazm/dotfiles) consume these.
      inherit homeModules;

      # ─── Home Manager configurations (legacy / direct activation) ────────
      homeConfigurations = {
        # macOS system configurations
        "gentleman-macos-intel" = mkHomeConfiguration "x86_64-darwin";
        "gentleman-macos-arm"   = mkHomeConfiguration "aarch64-darwin";

        # Default to Apple Silicon
        "gentleman" = mkHomeConfiguration "aarch64-darwin";
      };
    };
}
