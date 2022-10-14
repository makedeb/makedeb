@test "make sure rust code is formatted" {
    cargo fmt --check
}

@test "make sure cargo clippy lints pass" {
    cargo clippy -- -D warnings
}