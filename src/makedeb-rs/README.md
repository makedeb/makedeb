# makedeb-rs
This folder contains the Rust code used internally by makedeb. Currently, this is used for the following purposes:

- Dependency resolution and package installation (the `--sync-deps` and `--install` makedeb flags)
- Automatic removal of packages (the `--rm-deps` flag)