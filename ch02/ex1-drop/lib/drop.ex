defmodule Drop do
  @moduledoc """
  Documentation for Drop.
  """

  @doc """
  Calculates the velocity of an object falling on Earth as if it were in a vacuum (no air resistance). The distance is the height from which the object falls, specified in meters, and the function returns a velocity in meters per second
  """
  
  #@spec fall_velocity(number(), number()) :: float()
  
  def fall_velocity({planemo, distance}) when distance >= 0 do
    gravity = case planemo do
      :earth -> 9.8
      :moon -> 1.6
      :mars -> 3.71
    end
  :math.sqrt(2 * gravity * distance)
  end
  
end
