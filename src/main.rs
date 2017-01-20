/*
 * Analyze logs of the form
 * 2016-07-14 18:37:11.036686|INFO    |VirtualServerBase|1  |client connected 'crave'(id:249) from 84.133.64.99:38630
 * Output a csv containing
 * Timestamp, Active Users
 */

extern crate regex;

use std::io;
use std::io::BufRead;
use regex::Regex;
use std::collections::HashSet;

fn main() {
    let mut users = HashSet::new();
    let usr = Regex::new(r"^(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d{6})\|INFO\s+\|\s*\w+\s*\|\s*\d+\s*\| ?client (connected|disconnected) '.+'\(id:(\d+)\)").unwrap();
    let srv = Regex::new(r"^.?.?(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d{6})\|INFO\s+\|\s*\w+\s*\|\s*\d+\s*\| ?listening on").unwrap();
    println!("Timestamp, Users");
    let stdin = io::stdin();
    stdin.lock().lines().map(|l| {
        let line = l.unwrap();
        let caps = usr.captures(&line);
        match caps {
            Some(caps) => { 
                let timestamp = caps.at(1).unwrap(); 
                let mode = caps.at(2).unwrap();
                let id = caps.at(3).unwrap();
                let id: u64 = id.parse().unwrap();
                if mode == "connected" {
                    users.insert(id);
                } else if mode == "disconnected" {
                    users.remove(&id);
                }
                println!("{}, {}", timestamp, users.len());
            },
            None => {
                let caps = srv.captures(&line);
                match caps {
                    Some(caps) => {
                        users.clear();
                        let timestamp = caps.at(1).unwrap(); 
                        println!("{}, {}", timestamp, users.len());
                    },
                    None => {}
                }
            }
        }
    }).count();
}
