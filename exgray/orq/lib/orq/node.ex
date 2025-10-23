defmodule Orq.Node do
  require Logger

  def process_image(path, out_dir, master_pid) do
    filename = Path.basename(path)
    output_path = Path.join(out_dir, "gray_" <> filename)
    Logger.info("[#{node()}] processing #{filename}")
    {:ok, binary} = File.read(path)
    gray_binary = ImageNif.to_grayscale(binary)
    File.write!(output_path, gray_binary)
    send(master_pid, {:done, node(), filename})
  end
  
end
