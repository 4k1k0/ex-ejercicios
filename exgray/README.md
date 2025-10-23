# exgray

elixir + rust

## Install

```shell
cd orq
mix deps.get
mix compie
```

Example:

```elixir
iex> binary = File.read!("test.png")
iex> gray = ImageNif.to_grayscale(binary)
iex> File.write!("gray.png", gray)
:ok
```

### Cluster

| node | description |
|-|-|
| master | this is the orchestrator | 
| nodeA | single worker that uses a Rust NIF | 
| nodeB | single worker that uses a Rust NIF | 
| nodeC | single worker that uses a Rust NIF | 

### Configuration

- `master` node should install `nfs-kernel-server` and expose a shared HDD.
- `nodeX` should connect and use the shared HDD
