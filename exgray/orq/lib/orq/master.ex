defmodule Orq.Master do
  use GenServer
  require Logger

  @workers  [
    :"workerA@pi",
    :"workerB@pi",
    :"workerC@pi",
    :"workerD@pi",
  ]

  @path_in  "/mnt/shared/in"
  @path_out  "/mnt/shared/out"

  def start_link(_), do: GenServer.start_link(__MODULE__, %{}, name: __MODULE__)

  def init(_) do
    File.mkdir_p!(@path_out)
    {:ok, watcher_pid} = FileSystem.start_link(dirs: [@path_in])
    FileSystem.subscribe(watcher_pid)
    {:ok, %{index: 0}}
  end

  def handle_info({:file_event, _watcher_pid, {path, _events}}, state) do
    if String.ends_with?(path, [".jpg", ".png"]) do
      Logger.info("new image detected #{path}")
      next_worker = Enum.at(@workers, rem(state.index, length(@workers)))
      Node.spawn(next_worker, Orq.Node, :process_image, [path, @path_out, self()])
      {:noreply, %{state | index: state.index + 1}}
    else
      {:noreply, state}
    end
  end

  def handle_info({:done, worker, filename}, state) do
    Logger.info("worker #{worker} finished processing #{filename}")
    {:noreply, state}
  end
  
end
