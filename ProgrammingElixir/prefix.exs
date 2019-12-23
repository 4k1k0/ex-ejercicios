prefix = fn prefijo ->
  fn nombre ->
    "#{prefijo} #{nombre}"
  end
end

IO.puts(prefix.("Sr").("Wako"))
