use std::io::{self, BufRead, Write};
use blart::map::TreeMap;

fn main() -> io::Result<()> {
    let stdin = io::stdin();
    let mut lines = stdin.lock().lines();
    let mut stdout = io::stdout();

    let mut tree: Option<TreeMap<Box<[u8]>, u8>> = None;

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
                    let boxed: Box<[u8]> = key_str.as_bytes().to_vec().into_boxed_slice();
                    map.insert(boxed, 1u8);
                    write_resp("OK")?;
                } else {
                    write_resp("ERR no-tree")?;
                }
            }
            "SEARCH" => {
                if let (Some(ref map), Some(key_str)) = (&tree, arg) {
                    let slice: &[u8] = key_str.as_bytes();
                    if map.get(slice).is_some() {
                        write_resp("FOUND")?;
                    } else {
                        write_resp("NOTFOUND")?;
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

