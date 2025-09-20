defmodule EchoApp do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {EchoServer, "World"}
    ]

    opts = [strategy: :one_for_one, name: EchoSupervisor]

    Supervisor.start_link(children, opts)
  end
end
