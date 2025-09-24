defmodule RadixPort do
  @moduledoc """
  Wrapper for the Rust radix tree port.
  Supports CREATE, INSERT, and SEARCH commands.
  """

  use GenServer

  ## Public API

  @doc """
  Start the RadixPort GenServer.

  Example:
      {:ok, _pid} = RadixPort.start_link("/path/to/rust-port/target/release/rust-port")
  """
  def start_link(rust_exec) when is_binary(rust_exec) do
    GenServer.start_link(__MODULE__, rust_exec, name: __MODULE__)
  end

  @doc """
  Insert a UUID string into the radix tree.
  Returns :ok or {:error, reason}.
  """
  def insert(uuid) when is_binary(uuid) do
    GenServer.call(__MODULE__, {:insert, uuid})
  end

  @doc """
  Search for a UUID string in the radix tree.
  Returns true if found, false otherwise.
  """
  def search(uuid) when is_binary(uuid) do
    GenServer.call(__MODULE__, {:search, uuid})
  end

  @doc """
  Load UUIDs from a file line by line without loading into memory.
  """
  def ingest_file(path) when is_binary(path) do
    GenServer.call(__MODULE__, {:ingest_file, path}, :infinity)
  end

  ## GenServer callbacks

  def init(rust_exec) do
    port =
      Port.open({:spawn_executable, rust_exec}, [
        :binary,
        :exit_status
      ])

    send_command(port, "CREATE")

    receive do
      {^port, {:data, _data}} -> :ok
      {^port, {:exit_status, status}} -> {:stop, {:port_exited, status}}
    after
      1_000 -> :ok
    end


    {:ok, %{port: port}}
  end

  def handle_call({:insert, uuid}, _from, %{port: port} = state) do
    case transact(port, "INSERT " <> uuid) do
      "OK" -> {:reply, :ok, state}
      "ERR invalid-uuid" -> {:reply, {:error, :invalid_uuid}, state}
      other -> {:reply, {:error, {:unexpected, other}}, state}
    end
  end

  def handle_call({:search, uuid}, _from, %{port: port} = state) do
    case transact(port, "SEARCH " <> uuid) do
      "FOUND" -> {:reply, true, state}
      "NOTFOUND" -> {:reply, false, state}
      "ERR invalid-uuid" -> {:reply, {:error, :invalid_uuid}, state}
      other -> {:reply, {:error, {:unexpected, other}}, state}
    end
  end

  def handle_call({:ingest_file, path}, _from, %{port: port} = state) do
    if not File.exists?(path) do
      {:reply, {:error, :enoent}, state}
    else
      {time_us, _result} =
        :timer.tc(fn ->
          path
          |> File.stream!()
          |> Stream.chunk_every(1_000)
          |> Stream.each(fn chunk ->
            payload =
              chunk 
              |> Enum.map(fn item -> String.replace(item, "\n", "") end) 
              |> Enum.join(" ")
            input = "INSERT_CHUNK " <> payload

            transact(port, input)
          end)
          |> Stream.run()
        end)

      IO.puts("Ingestion took #{time_us / 1_000_000} seconds")
      {:reply, :ok, state}
    end
  end

  defp send_command(port, cmd) do
    Port.command(port, cmd <> "\n")
  end

  defp transact(port, cmd) do
    send_command(port, cmd)

    receive do
      {^port, {:data, data}} ->
        data |> to_string() |> String.trim()

      {^port, {:exit_status, status}} ->
        {:error, {:port_exited, status}}
    after
      5_000 ->
        {:error, :timeout}
    end
  end
end

