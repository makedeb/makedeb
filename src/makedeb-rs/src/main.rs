use clap::{Parser, Subcommand};

mod autoremove;
mod cache;
mod install;
mod message;
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
    Install {
        /// The '.deb' packages to install.
        #[arg(required = true)]
        pkgs: Vec<String>,

        /// Allow packages to be downgraded
        #[arg(long)]
        allow_downgrades: bool,

        /// Don't ask before installing packages
        #[arg(long)]
        no_confirm: bool,

        /// Fail if changes to the cache would be made
        #[arg(long, requires("deps_only"))]
        fail_on_change: bool,

        /// Only install the deps of this package
        #[arg(long)]
        deps_only: bool,

        /// Mark built '.deb' packages as automatically installed.
        #[arg(long, conflicts_with("deps_only"))]
        as_deps: bool,
    },

    Autoremove {
        /// Don't ask before removing packages
        #[arg(long)]
        no_confirm: bool,

        /// Dummy argument for compatibility with makedeb.
        #[arg(long)]
        allow_downgrades: bool,
    },
}

#[quit::main]
fn main() {
    let cli = Cli::parse();

    match cli.command {
        Commands::Install {
            pkgs,
            allow_downgrades,
            no_confirm,
            fail_on_change,
            deps_only,
            as_deps,
        } => install::install(
            pkgs,
            allow_downgrades,
            no_confirm,
            fail_on_change,
            deps_only,
            as_deps,
        ),
        Commands::Autoremove {
            no_confirm,
            allow_downgrades: _,
        } => autoremove::autoremove(no_confirm),
    }
}
