#![feature(bool_to_option)]

use std::path::Path;
use log::*;
use simplelog::*;
use std::time::{Instant};
use clap::{Arg, App};

mod checkloc;
use checkloc::checkloc;
mod average;
use average::average_all_images;
#[macro_use] extern crate lalrpop_util;

fn main() {
    CombinedLogger::init(
        vec![
            TermLogger::new(LevelFilter::Debug, Config::default(), TerminalMode::Mixed),
        ]
    ).unwrap();

    let mut app = App::new("krtools")
        .version("1.0")
        .author("Pedro M. <pmgberm@gmail.com>")
        .about("Does things the KR way")
        .subcommand(App::new("average").arg(Arg::new("image_directory").required(true)))
        .subcommand(App::new("checkloc").arg(Arg::new("pdx_directory").required(true)))
        .subcommand(App::new("styletransfer").arg(Arg::new("style_file").required(true)).arg(Arg::new("apply_file").required(true)));
    let matches = app.to_owned().get_matches();

    let start = Instant::now();
    match matches.subcommand() {
        Some(("average", args)) => {
            args.value_of("image_directory").and_then(|e| {
                let path = Path::new(e);
                average_all_images(path);
                Some(e)
            });
        }
        Some(("checkloc", args)) => {
            args.value_of("pdx_directory").and_then(|e| {
                let path = Path::new(e);
                checkloc(path);
                Some(e)
            });
        }
        _ => {
            error!(target: "kr_style_transfer", "Unknown or unimplemented subcommand");
            app.print_long_help();
        }
    }
    info!(target: "kr_style_transfer", "Finished in {:?} seconds", start.elapsed().as_secs());
}
