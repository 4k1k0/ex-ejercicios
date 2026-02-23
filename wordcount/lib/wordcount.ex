defmodule Wordcount do

  @type word_frequencies() :: %{String.t() => non_neg_integer()}
  @type error() :: {:error, String.t()}
  @type response() :: {:ok, word_frequencies()} | error()

  @spec process(String.t()) :: response()
  def process(filename) do
    case File.read(filename) do
      {:ok, content} -> {:ok, process_content(content) }
      {:error, _} -> {:error, "invalid input"}
    end
  end

  defp process_content(content) do
    content
    |> String.split(" ")
    |> Enum.filter(fn (c) -> c != "" end)
    |> Enum.frequencies()
  end
end
