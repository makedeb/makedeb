# Contributing
Welcome! We're glad you're looking into contributing to makedeb - we can always use some extra hands to get things moving, and your help is greatly appreciated.

## Translations
If you'd like to help with translations for the makedeb project, visit the [Weblate page](https://weblate.makedeb.org/projects/makedeb/makedeb).

[![Translation status](https://weblate.makedeb.org/widgets/makedeb/-/makedeb/multi-auto.svg)](https://weblate.makedeb.org/projects/makedeb/makedeb)

## Code contributions
### Setting up your local system
You'll first need to have forked and cloned the repository of course. Instructions for doing such are plethorous on the internet, but if you find yourself still needing help, feel free to hop into [#makedeb-project:hunterwittenborn.com](https://matrix.to/#/#makedeb-project:hunterwittenborn.com) on Matrix or the `makedeb` room on [Discord](https://docs.makedeb.org/support/obtaining-support/#discord).

### Setting up Git hooks
The project utilizes a few Git hooks to help make things a bit easier when changing certain files, with those notably being man pages at current.

To install the Git hooks, you can run the following from inside of your cloned repository:

```sh
git config --local core.hooksPath "$(git rev-parse --show-toplevel)/.githooks/"
```

### Code styling
We have some basic code styling guidelines to help keep the entire project looking uniform. These aren't hard guidelines, and you can break them if you think it'll help with the maintainability of code, but please try to follow them unless you have a good reason to do otherwise.

#### Variables
All variables should be in the `${}` format.

I.e., do this:

```sh
"${var}"
```

and not this:

```sh
"$var"
```

#### If, For, and While statements
We put the `then` and `do` clauses on the same line as the declaration for the statement.

I.e., do this:

```sh
if [[ "${var}" == "foo" ]]; then
    echo "true"
fi

while true; do
    echo "true"
done
```

#### Indentation
For indentation, we use four spaces, formatted as space characters. Not all code currently follows this guideline, though all new code needs to follow such.

### Running unit tests
All PRs on GitHub automatically run through GitHub Actions to ensure that your code is working properly.

If preferred, you can also first run unit tests before pushing your changes.

#### Needed packages
To run unit tests, you'll need [Toast](https://github.com/stepchowfun/toast) installed.

##### MPR
[Toast is available on the MPR](https://mpr.makedeb.org/packages/toast) if you want to install Toast with makedeb. You'll likely also need the latest version of the Rust compiler toolchain, which is [also available on the MPR](https://mpr.makedeb.org/packages/rustc).

```sh
# Rust toolchain.
# Note that this may take several hours to build.
git clone 'https://mpr.makedeb.org/rustc'
cd rustc/
makedeb -si

# Toast.
git clone 'https://mpr.makedeb.org/toast'
cd toast/
makedeb -si
```

##### Prebuilt-MPR
Rust and Toast can take a while to build, which some users may wish to avoid. If you'd prefer to have a prebuilt package, which remediates this issue, you can obtain Toast from the [Prebuilt-MPR](https://docs.makedeb.org/prebuilt-mpr). After setting up the Prebuilt-MPR, just run the following to install Toast:

```sh
sudo apt install toast
```
