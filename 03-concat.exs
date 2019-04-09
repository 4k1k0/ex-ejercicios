prefix = fn ( first ) ->
  fn sufix -> first <> " " <> sufix
  end
end

mrs = prefix.("Mrs")
IO.puts mrs.("Wako")