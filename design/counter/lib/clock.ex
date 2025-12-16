defmodule Clock do
  def start(f) do
    run(f, 0)
  end

  def run(your_heart_desire, count) do
    your_heart_desire.(count)
    new_counter = Counter.Core.inc(count)
    :timer.sleep(1_000)
    run(your_heart_desire,new_counter)
  end
  
end
