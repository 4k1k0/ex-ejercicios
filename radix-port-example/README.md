# Radix port example (Elixir <-> Rust via Port)

This example demonstrates maintaining an Adaptive Radix Tree (ART) in Rust (using the `blart` crate) and interacting with it from Elixir via a Port. Each line of the input file contains a UUID (or any string key). Elixir streams the file line-by-line and sends `INSERT <key>` commands to the Rust port. After ingesting the file, call `RadixPort.search("...")` to check membership.

> The Rust crate `blart` (Adaptive Radix Tree) is used on the Rust side. See blart docs: https://docs.rs/blart. :contentReference[oaicite:2]{index=2}

## Build the Rust port

From repository root:

```bash
cd rust_port
cargo build --release
```
