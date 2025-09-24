use blart::map::TreeMap;
use std::io::{self, BufRead, Write};
use uuid::Uuid;

fn main() -> io::Result<()> {
    let stdin = io::stdin();
    let mut lines = stdin.lock().lines();
    let mut stdout = io::stdout();

    // Use [u8; 16] as the key type
    let mut tree: Option<TreeMap<[u8; 16], u8>> = None;

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
        let mut parts = line.splitn(2, ' ');
        let cmd = parts.next().unwrap().to_uppercase();
        let arg = parts.next();

        match cmd.as_str() {
            "CREATE" => {
                tree = Some(TreeMap::new());
                write_resp("OK")?;
            }
            "INSERT" => {
                if let (Some(ref mut map), Some(key_str)) = (&mut tree, arg) {
                    match Uuid::parse_str(key_str) {
                        Ok(uuid) => {
                            map.insert(*uuid.as_bytes(), 1u8);
                            write_resp("OK")?;
                        }
                        Err(_) => {
                            write_resp("ERR invalid-uuid")?;
                        }
                    }
                } else {
                    write_resp("ERR no-tree")?;
                }
            }
            "SEARCH" => {
                if let (Some(ref map), Some(key_str)) = (&tree, arg) {
                    match Uuid::parse_str(key_str) {
                        Ok(uuid) => {
                            if map.get(uuid.as_bytes()).is_some() {
                                write_resp("FOUND")?;
                            } else {
                                write_resp("NOTFOUND")?;
                            }
                        }
                        Err(_) => {
                            write_resp("ERR invalid-uuid")?;
                        }
                    }
                } else {
                    write_resp("ERR no-tree")?;
                }
            }
            _ => {
                write_resp(&format!("ERR unknown-cmd {}", cmd))?;
            }
        }
    }
    Ok(())
}
