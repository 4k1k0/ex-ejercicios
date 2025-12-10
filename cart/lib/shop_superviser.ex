defmodule ShopSupervisor do
  use Supervisor

  def start_link() do
    IO.puts("shop superviser starting...")
    Supervisor.start_link(__MODULE__, :ok, name: :shop_supervisor)
  end

  def init(_init_arg) do
    children = [
      CartSupervisor
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
