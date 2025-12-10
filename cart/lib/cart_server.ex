defmodule CartServer do
  use GenServer

  # client
  def start_link do
    GenServer.start_link(CartServer, %{}, name: :cart_server)
  end

  def cart_total, do: GenServer.call(:cart_server, :total)

  def add_item(item), do: GenServer.cast(:cart_server, {:add_item, item})

  # callbacks

  @impl true
  def init(_state) do
    {:ok, %{cart: [], timer_pid: nil}}
  end

  @impl true
  def handle_call(:total, _from, state) do
    total =
      state.cart
      |> Enum.reduce(0, fn item, acc -> acc + item[:price] * item[:qty] end)

    {:reply, total, state}
  end

  @impl true
  def handle_cast({:add_item, item}, state) do
    new_state =
      %{state | cart: [item | state.cart]}
      |> reminder_timer()

    {:noreply, new_state}
  end

  @impl true
  def handle_info(:reminder, state) do
    IO.puts("dont forget about those item you need")
    {:noreply, state}
  end

  defp reminder_timer(state) do
    case state[:timer_pid] do
      nil ->
        %{state | timer_pid: Process.send_after(self(), :reminder, 10_000)}

      _ ->
        Process.cancel_timer(state[:timer_pid])
        %{state | timer_pid: Process.send_after(self(), :reminder, 10_000)}
    end
  end
end
