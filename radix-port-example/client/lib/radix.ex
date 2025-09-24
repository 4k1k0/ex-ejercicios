defmodule RadixPort do
  @moduledoc """
  Simple GenServer that manages the Rust port (radix tree).
  """

  use GenServer

  ## Public API

  @doc """
  Start the radix port manager.

  `rust_executable` should be the path to the compiled rust binary.
  """
  def start_link(rust_executable) when is_binary(rust_executable) do
    GenServer.start_link(__MODULE__, rust_executable, name: __MODULE__)
  end

  @doc """
  Stream a file line by line and insert each uuid (line) into the Rust ART.

  Returns :ok or {:error, reason}
  """
  def ingest_file(path) when is_binary(path) do
    GenServer.call(__MODULE__, {:ingest_file, path}, :infinity)
  end

  @doc """
  Search the ART for the given query string. Returns true/false.
  """
  def search(query) when is_binary(query) do
    GenServer.call(__MODULE__, {:search, query})
  end

  ## GenServer callbacks

  def init(rust_executable) do
    # open the port
    port =
      Port.open({:spawn_executable, rust_executable}, [
        {:args, []},
        :binary,
        :exit_status
      ])

    # ask Rust to create the tree
    send_command(port, "CREATE")

    {:ok, %{port: port}}
  end

  def handle_call({:ingest_file, path}, _from, state) do
    if not File.exists?(path) do
      {:reply, {:error, :enoent}, state}
    else
      # stream file line-by-line; default chunk size and :line will stream by line
      stream = File.stream!(path, [], :line)

      Enum.each(stream, fn line ->
        uuid = String.trim(line)
        # skip empty lines
        if uuid != "" do
          send_command(state.port, "INSERT " <> uuid)
          # optionally we could check OK response — we'll ignore for simplicity
          wait_for_ok(state.port)
        end
      end)

      {:reply, :ok, state}
    end
  end

  def handle_call({:search, query}, _from, state) do
    send_command(state.port, "SEARCH " <> query)

    case receive_port_response(state.port, 5_000) do
      {:ok, "FOUND"} -> {:reply, true, state}
      {:ok, "NOTFOUND"} -> {:reply, false, state}
      {:ok, resp} -> {:reply, {:error, {:unexpected, resp}}, state}
      {:error, reason} -> {:reply, {:error, reason}, state}
    end
  end

  # handle port exit
  def handle_info({port, {:exit_status, status}}, %{port: port} = state) do
    # port exited; escalate or mark unavailable
    {:noreply, Map.put(state, :exited, status)}
  end

  # Unknown messages from port come as {port, {:data, data}}
  def handle_info({port, {:data, _data}}, state) when port == state.port do
    # We don't handle unsolicited messages here; they are caught by receive_port_response
    {:noreply, state}
  end

  defp send_command(port, command) do
    # Port.command expects a binary
    Port.command(port, :erlang.iolist_to_binary([command, "\n"]))
  end

  defp wait_for_ok(port, timeout \\ 2_000) do
    case receive_port_response(port, timeout) do
      {:ok, "OK"} -> :ok
      {:ok, other} -> {:error, {:unexpected, other}}
      {:error, reason} -> {:error, reason}
    end
  end

  # waits for a single newline-terminated response from the port
  defp receive_port_response(port, timeout) do
    receive do
      {^port, {:data, data}} ->
        # data is binary; may contain newline; trim and return
        resp = data |> to_string() |> String.trim()
        {:ok, resp}

      {^port, {:exit_status, status}} ->
        {:error, {:port_exited, status}}
    after
      timeout ->
        {:error, :timeout}
    end
  end
end

