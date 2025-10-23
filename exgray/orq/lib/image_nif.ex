defmodule ImageNif do
  use Rustler, otp_app: :orq, crate: "imagenif"

  def to_grayscale(_binary), do: :erlang.nif_error(:nif_not_loaded)
end

