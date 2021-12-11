# Setting up your local system
You'll first need to have forked and cloned the repository of course. Instructions for doing such are plethorous on the internet, but if you find yourself still needing help, feel free to hop into [#makedeb-contributing:hunterwittenborn.com](https://matrix.to/#/#makedeb-contributing:hunterwittenborn.com).

## Setting up Git hooks
The project utilizes a few Git hooks to help make things a bit easier when changing certain files, with those notably being man pages at current.

To install the Git hooks, you can run the following from inside of your cloned repository:

```sh
git config --local core.hooksPath "$(git rev-parse --show-toplevel)/.githooks/"
```

# Cody styling
When creating any kind of function, create its file inside of the `src/functions/` folder with a suffix of `.sh`. Function files should be isolated and only contain a single function.

All files inside of `src/functions/` are squished into a single file, alongside the main `src/makedeb.sh` file, at build time, so it is important that function files only contain the function data, and nothing else.

If for whatever reason you need to remove any lines of code at build time (such is the case for the function file squishing mentioned above), add the `# COMP_RM` suffix at the end of the relevant lines, all of which get removed during builds.
