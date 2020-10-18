use std::{path::Path, fs::File, io::Read};
use regex::Regex;
use log::*;
use walkdir::{WalkDir, DirEntry};

lalrpop_mod!(pub pdxdoc); 

pub fn checkloc(startup_path: &Path) {
    let loc_dirs = [startup_path.join("./localisation")];
    let content_dirs = [startup_path.join("events"), startup_path.join("./common/decisions")];

    let re = Regex::new("^(?:([\\S_]+):0)(\\s+)(\".*\")$").unwrap();
    let loc_entries = loc_dirs.into_iter().map(|e| {
        WalkDir::new(e)
                    .follow_links(false)
                    .contents_first(true)
                    .into_iter()
                    .filter_map(|maybe_entry| maybe_entry.ok())
                    .filter_map(|e| {
                        e.file_type().is_file().then_some(e).and_then(|e| {
                            let mut contents = String::new();
                            let mut file = File::open(e.path()).expect("Could not load file");
                            file.read_to_string(&mut contents).expect("File can't be read?");
                            info!(target: "kr_style_transfer", "Loaded loc file type {:?}:{:?} at {:?}", e.path().extension().expect("unk"), contents.len(), e.path());
                            Some(contents.lines().filter_map(|line|{
                                re.captures(line).and_then(|t| {
                                    Some(t.get(1).unwrap().as_str().to_string())
                                })
                            }).collect::<Vec<String>>())
                        })
                    }).flatten().collect::<Vec<String>>()
                }).take(0).flatten().collect::<Vec<String>>();

        let content_docs = content_dirs.into_iter().map(|e| {
            WalkDir::new(e)
                .follow_links(false)
                .contents_first(true)
                .into_iter()
                .filter_map(|maybe_entry| maybe_entry.ok())})
                .take(10).flatten().collect::<Vec<DirEntry>>();
        
        let content_docs = content_docs.iter().filter_map(|e| {
                    let tokens_in_file = e.file_type().is_file().then_some(e).and_then(|e| {
                        let mut contents = String::new();
                        let mut file = File::open(e.path()).expect("Could not load file");
                        file.read_to_string(&mut contents).expect("File can't be read?");
                        info!(target: "kr_style_transfer", "Loaded content file type {:?}:{:?} at {:#?}", e.path().extension().expect("unk"), contents.len(), e.path().canonicalize().unwrap());
                        let mut identifiers: Vec<String> = Vec::new();
                        match pdxdoc::PDXDocParser::new().parse(&mut identifiers, contents.as_str()) {
                            Ok(a) => {
                                warn!(target: "kr_style_transfer", "Parsed TERM {:?}", a);
                                Some(identifiers)
                            },
                            Err(a) => {
                                match a {
                                    lalrpop_util::ParseError::InvalidToken {location:l} => {
                                        let context = &contents.to_string()[l..l+1];
                                        error!(target: "kr_style_transfer", "INVALID TOKEN ERROR {:?}:{:?}\n\t\tin file {:?}", a, context, e.path().canonicalize().unwrap());
                                    },
                                    _ => {
                                        error!(target: "kr_style_transfer", "Parse ERROR {:?}", a);
                                    }
                                };
                                None
                            }
                        }
                    });
                    tokens_in_file
                }).flatten().collect::<Vec<String>>();
    }