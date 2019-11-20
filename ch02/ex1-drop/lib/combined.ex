defmodule Combined do
  @moduledoc """
  Documentation for Combinend.
  """

  def height_to_mpg(meters) do
    Drop.fall_velocity(meters)
    |> Convert.mps_to_mph
  end

end
