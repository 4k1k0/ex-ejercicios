defmodule Drop do
  @moduledoc """
  Documentation for Drop.
  """

  @doc """
  Calculates the velocity of an object falling on Earth as if it were in a vacuum (no air resistance). The distance is the height from which the object falls, specified in meters, and the function returns a velocity in meters per second
  """
  
  @spec fall_velocity(number(), number()) :: float()
  
  def fall_velocity(:earth, distance) do
    :math.sqrt(2 * 9.8 * distance)
  end

  def fall_velocity(:moon, distance) do
    :math.sqrt(2 * 1.6 * distance)
  end

  def fall_velocity(:mars, distance) do
    :math.sqrt(2 * 3.71 * distance)
  end

end
