# Nix-Powered Development Environment

After you've [cloned Synapse locally](contributing_guide.md#3-get-the-source), you will find
a [flake.nix](https://github.com/matrix-org/synapse/blob/develop/flake.nix) file in the root
of the repository. This is a [Nix Flake](https://nixos.wiki/wiki/Flakes), and can be used to
tell Nix to construct a deterministic development environment (among other things).

> [Nix](https://nixos.org/) is a package manager that can be installed on existing Linux and
> MacOS systems and can be used to install and configure specific versions of software. It
> shines as a tool to install and configure all necessary software for your development
> environment at the exact version that other Synapse developers are using.
> 
> This helps new contributors get started quicker, helps cut down on "works on my machine"
> behaviour and does not require containers or VMs.

Assuming you have [installed Nix](https://github.com/nixOS/nix#installation) and
[enabled flake support in nix](https://nixos.wiki/wiki/Flakes#Enable_flakes), simply run
`nix develop` from your local Synapse checkout.

Nix will now begin to download and install all dependencies specified in `flake.nix`,
including Poetry and Rust. Once it completes, you will be dropped into a shell where
all development tools will be available.

## Using `direnv` to automatically activate the development environment

While it's convenient to have this development shell available, having to type
`nix develop` every time you want to activate it is a little cumbersome. We can
make this easier with `direnv`, a tool to automatically activate development
environments upon entering a directory in your shell.

Install [direnv](https://direnv.net/) and create a file named `.envrc` with the
following contents at the root of your Synapse checkout:

```
# Install nix-direnv, an improved implementation of direnv's use_nix/use_flake
if ! has nix_direnv_version || ! nix_direnv_version 2.2.0; then
  source_url "https://raw.githubusercontent.com/nix-community/nix-direnv/2.2.0/direnvrc" "sha256-5EwyKnkJNQeXrRkYbwwRBcXbibosCJqyIUuz
9 q+LRc="
fi

# Activate the development shell of the local flake.nix file
use flake
```

Then run `direnv allow .` at the root of your Synapse checkout and watch direnv
automatically activate and enter the development shell for you! If you `cd` out
of your Synapse checkout, the development shell will deactivate automatically
and vice versa.

## Activate the development shell from your IDE

To make the tools and environment variables of the development shell available to your
IDE, you may have found that you can simply launch your IDE from the command line after
activating the development environment. While this works, it is cumbersome, and we can 
do better.

We can make use of the `.envrc` file that was created in the
[direnv section above](#using-direnv-to-automatically-activate-the-development-environment)
to load the development environment from your IDE.

### PyCharm

Install the [direnv integration](https://plugins.jetbrains.com/plugin/15285-direnv-integration)
plugin and restart PyCharm. Open your Synapse checkout, and when a pop-up appears asking
you whether you want to load the `.envrc` file it found, choose "import direnv".

### VSCode

Install the [direnv](https://marketplace.visualstudio.com/items?itemName=mkhl.direnv) extension
and reload VSCode. It's as simple as that!

> Tip: VSCode loads all extension at once, and extensions cannot request a load order. If an
> extension that requires a tool in your development environment is loaded before the `direnv`
> extension, then it may fail to initialise. This can be especially prevalent with the Golang
> extension and Complement: https://github.com/direnv/direnv-vscode/issues/109.
> 
> The workaround in this case - until VSCode extensions gain support for load priority - is to
> is to close all open `.go` file tabs and then restart VSCode. The Golang extension does not
> try to run `go` until a `.go` file is opened, so this can be used to mitigate the race condition.