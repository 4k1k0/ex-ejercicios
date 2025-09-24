use std::io::{self, BufRead, Write};
use blart::map::TreeMap;

fn main() -> io::Result<()> {
    let stdin = io::stdin();
    let mut lines = stdin.lock().lines();

    // Option to hold the tree once created.
    let mut tree: Option<TreeMap<Vec<u8>, u8>> = None;

    // Helper to write response to stdout and flush
    let mut stdout = io::stdout();
    let mut write_resp = |s: &str| -> io::Result<()> {
        stdout.write_all(s.as_bytes())?;
        stdout.write_all(b"\n")?;
        stdout.flush()
    };

    while let Some(Ok(line)) = lines.next() {
        let line = line.trim_end().to_string();
        if line.is_empty() {
            continue;
        }

        // Split into command and rest
        let mut parts = line.splitn(2, ' ');
        let cmd = parts.next().unwrap().to_uppercase();
        let arg = parts.next().map(str::trim);

        match cmd.as_str() {
            "CREATE" => {
                tree = Some(TreeMap::new());
                if let Err(e) = write_resp("OK") {
                    eprintln!("failed to write OK: {}", e);
                    break;
                }
            }
            "INSERT" => {
                match (&mut tree, arg) {
                    (Some(ref mut map), Some(key)) => {
                        // store the raw bytes of the string key
                        map.insert(key.as_bytes().to_vec(), 1u8);
                        if let Err(e) = write_resp("OK") {
                            eprintln!("failed to write OK: {}", e);
                            break;
                        }
                    }
                    _ => {
                        let _ = write_resp("ERR no-tree");
                    }
                }
            }
            "SEARCH" => {
                match (&tree, arg) {
                    (Some(ref map), Some(key)) => {
                        let found = map.get(&key.as_bytes().to_vec()).is_some();
                        if found {
                            let _ = write_resp("FOUND");
                        } else {
                            let _ = write_resp("NOTFOUND");
                        }
                    }
                    _ => {
                        let _ = write_resp("ERR no-tree");
                    }
                }
            }
            _ => {
                let _ = write_resp(&format!("ERR unknown-cmd {}", cmd));
            }
        }
    }

    Ok(())
}

