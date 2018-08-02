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
end
