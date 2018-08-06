defmodule Input do
  use Agent

  def start_link() do
    Agent.start_link(fn -> {[], 0, false} end, name: __MODULE__)
  end

  def get_input() do
    next = IO.gets("")
    Catholicon.convert(Agent.get_and_update(__MODULE__, fn {input, drop, stream} ->
      if next == :eof or stream do
        value = Stream.cycle(input)
          |> Stream.drop(drop)
          |> Enum.at(0)
        {value, {input, drop+1, true}}
      else
        next = String.replace_trailing(next, "\n", "")
        {next, {input ++ [next], drop, false}}
      end
    end))
  end

  def get_input(index) do
    get_until(index)
    {input, drop, stream} = Agent.get(__MODULE__, fn x -> x end)
    IO.inspect {input, drop, stream, index}
    Enum.at(input, rem(index, length(input)))
  end

  defp get_until(index) do
    {input, _, stream} = Agent.get(__MODULE__, fn x -> x end)
    if index >= length(input) and not stream do
      IO.inspect {input, index, stream}, label: "a"
      get_input()
      get_until(index)
    end
  end
end
