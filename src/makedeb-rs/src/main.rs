use clap::{Parser, Subcommand};

mod message;
mod resolve;
mod util;

#[derive(Parser)]
#[command(author, version, about, long_about = None)]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    /// Resolve the deps for local '.deb' packages
    Resolve {
        /// The '.deb' packages to install. Separated into pkgname/version/deb pairs, separated by a '!' (i.e. 'cf983547f2d5a73c539ee62504552081!1.0.0!cf983547f2d5a73c539ee62504552081.deb').
        /// These package names should be random and not a package that normally exists in the cache, as the package itself will not be marked for installation.
        #[arg(required = true)]
        pkgs: Vec<String>,

        /// Allow packages to be downgraded
        #[arg(long)]
        allow_downgrades: bool,

        /// Don't ask before installing packages
        #[arg(long)]
        no_confirm: bool,

        /// Fail if changes to the cache would be made
        #[arg(long)]
        fail_on_change: bool,
    },
}

#[quit::main]
fn main() {
    let cli = Cli::parse();

    match cli.command {
        Commands::Resolve {
            pkgs,
            allow_downgrades,
            no_confirm,
            fail_on_change,
        } => resolve::resolve(pkgs, allow_downgrades, no_confirm, fail_on_change),
    }
}
