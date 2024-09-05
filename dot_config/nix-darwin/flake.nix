{
  description = "Example Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs }:
  let
    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [ pkgs.vim
        ];

      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;
      # nix.package = pkgs.nix;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Create /etc/zshrc that loads the nix-darwin environment.
      programs.zsh.enable = true;  # default shell on catalina
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 4;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";

      security.pam.enableSudoTouchIdAuth = true;

      system.defaults = {
        # macOS dock hides automatically
        dock.autohide = true;

        # Don’t rearrange spaces based on the most recent use
        dock.mru-spaces = false;

        # Finder shows all file extensions
        finder.AppleShowAllExtensions = true;

        # Default Finder folder view is the columns view
        finder.FXPreferredViewStyle = "clmv";

        # The login window shows a specific text as a greeting
        loginwindow.LoginwindowText = "If found: 514-575-5328";

        # When taking screenshots, store these in a specific folder
        screencapture.location = "~/Desktop";

        # Only ask for a password in the screensaver if it is running for longer than 10 seconds
        screensaver.askForPasswordDelay = 10;

        # Displays have separate spaces
        spaces.spans-displays = true;
      };

      nix.extraOptions = ''
        extra-platforms = x86_64-darwin aarch64-darwin
      '';

    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
    darwinConfigurations."kusanagi" = nix-darwin.lib.darwinSystem {
      modules = [ configuration ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."kusanagi".pkgs;
  };
}
