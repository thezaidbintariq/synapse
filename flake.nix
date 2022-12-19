{
  description = "A Synapse development environment";

  # This overlay allows us to choose rust versions other than latest if desired,
  # as well as provides the rust-src extension.
  inputs.rust-overlay.url = "github:oxalica/rust-overlay";

  # Define our outputs (what this flake produces; a development shell).
  outputs = {
    self,
    nixpkgs,
    flake-utils,
    rust-overlay,
  }:
    # Build a shell for every platform supported by Nix.
    flake-utils.lib.eachDefaultSystem
    (system: let
      overlays = [ (import rust-overlay) ];

      # Source our packages from nixpkgs, and supply the rust overlay.
      pkgs = import nixpkgs {
        inherit system overlays;
      };

      # Select the latest, stable rust release.
      rust_version = "latest";

      # We build a 'rust' package with our selected version and extensions.
      rust = pkgs.rust-bin.stable.${rust_version}.default.override {
        extensions = [
          # Allows jumping into the rust source code in your IDE
          "rust-src"
        ];
      };
    in {
      # Define a development shell.
      devShells.default = pkgs.mkShell {
        # The native dependencies to install in this development shell.
        buildInputs = with pkgs; [
          # For running Synapse.
          # postgresql must be installed and started separately. and redis...
          icu
          libffi
          libjpeg
          libpqxx
          libwebp
          libxml2
          libxslt
          sqlite

          # To manage Python dependencies
          poetry

          # For linting Synapse
          ruff

          # For building Synapse's documentation
          mdbook

          # For writing and building Rust
          rust
          cargo
          clippy
          rustfmt

          # For running Synapse's unit tests
          openssl

          # For running the Complement integration test suite
          go
          olm
        ];

        # Set RUST_SRC_PATH environment variable for rust-analyzer and other tools
        # to make use of.
        RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
      };
    });
}
