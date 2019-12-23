# Tengo que reparar
# esta mierda

fizzbuzz = fn(a, b, c) ->

  if a == 0 && b == 0 do
    "FizzBuzz"
  end

  if a == 0 do
    "Fizz"
  end

  if b == 0 do
    "Buzz"
  end

  if a != 0 && b != 0 do
    "#{c}"
  end

end

IO.puts fizzbuzz.(1, 2, 3)
IO.puts fizzbuzz.(0, 2, 3)
IO.puts fizzbuzz.(0, 0, 3)