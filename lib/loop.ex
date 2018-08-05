defmodule Loop do
  def while_unchanging(fun, acc_fun), do: do_while_unchanging(fun, fun.(acc_fun))
  defp do_while_unchanging(fun, prev) do
    loop(prev)
    value = fun.(fn -> prev end)
    if value == prev do
      value
    else
      do_while_unchanging(fun, value)
    end
  end

  def decompose(num, fun), do: do_decompose(num, num, fun, [])
  defp do_decompose(_check, 0, _fun, decomposition), do: decomposition
  defp do_decompose(check, num, fun, decomposition) do
    loop(check)
    if fun.(check) do
      new_num = num - check
      do_decompose(new_num, new_num, fun, decomposition ++ [check])
    else
      do_decompose(check - 1, num, fun, decomposition)
    end
  end

  def map(list, fun) do
    Enum.map(list, fn x -> loop(x); fun.(x) end)
  end

  defp loop(set), do: Variables.put("loop", set)
end
