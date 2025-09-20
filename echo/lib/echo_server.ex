defmodule EchoServer do
  use GenServer

  ## Client API

  def start_link(name) do
    GenServer.start_link(__MODULE__, name, name: __MODULE__)
  end

  # Public function to say hello immediately
  def say(name) do
    GenServer.call(__MODULE__, {:say, name})
  end

  # Update default name
  def update_name(new_name) do
    GenServer.cast(__MODULE__, {:update_name, new_name})
  end

  ## Server Callbacks

  @impl true
  def init(default_name) do
    schedule_work()
    {:ok, default_name}
  end

  @impl true
  def handle_call({:say, name}, _from, state) do
    greeting = Echo.say_hello(name)
    IO.puts(greeting)
    {:reply, greeting, state}
  end

  @impl true
  def handle_cast({:update_name, new_name}, _state) do
    IO.puts("Updated default name to: #{new_name}")
    {:noreply, new_name}
  end

  @impl true
  def handle_info(:work, name) do
    greeting = Echo.say_hello(name)
    IO.puts(greeting)

    schedule_work()
    {:noreply, name}
  end

  # Helper to schedule work every 20 seconds
  defp schedule_work do
    Process.send_after(self(), :work, 2_000)
  end
end

