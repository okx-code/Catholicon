defmodule Loop do
  def while_unchanging(fun, acc_fun), do: do_while_unchanging(fun, fun.(acc_fun))
  defp do_while_unchanging(fun, prev) do
    value = fun.(fn -> prev end)
    if value == prev do
      value
    else
      do_while_unchanging(fun, value)
    end
  end
end
