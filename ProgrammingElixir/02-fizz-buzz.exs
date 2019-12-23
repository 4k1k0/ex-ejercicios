fizzbuzz = fn
  {0, 0, _} -> IO.puts("Fizz")
  {0, _, _} -> IO.puts("Buzz")
  {_, _, n} -> IO.puts("#{n}")
end

IO.puts fizzbuzz.({1, 2, 3})
IO.puts fizzbuzz.({0, 2, 0})
IO.puts fizzbuzz.({0, 0, 8})
