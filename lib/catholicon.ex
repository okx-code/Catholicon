defmodule Catholicon do
  @table "ȦḂĊḊĖḞĠḢİJ̇\nK̇L̇ṀṄȮṖQ̇ṘṠṪU̇V̇ẆẊẎŻȧḃċḋė !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~ḟġḣi̇j̇k̇l̇ṁṅȯṗq̇ṙṡṫu̇v̇ẇẋẏżẠḄC̣ḌẸF̣G̣ḤỊJ̣ḲḶṂṆỌP̣Q̣ṚṢṬỤṾẈX̣ỴẒạḅc̣ḍẹf̣g̣ḥịj̣ḳḷṃṇọp̣q̣ṛṣṭụṿẉx̣ỵẓÅB̊C̊D̊E̊F̊G̊H̊I̊J̊K̊L̊M̊N̊O̊P̊Q̊R̊S̊T̊ŮV̊W̊X̊Y̊Z̊åb̊c̊d̊e̊f̊g̊h̊i̊j̊k̊l̊m̊n̊o̊p̊q̊r̊s̊t̊ův̊ẘx̊ẙz̊²√≠½"

  def main(args) do
    256 = String.length(@table)
    256 = length(String.graphemes(@table))

    {options, args, []} = OptionParser.parse(args,
      strict: [eval: :boolean, unicode: :boolean, silent: :boolean, literal: :boolean],
      aliases: [e: :eval, u: :unicode, s: :silent, l: :literal])
    code = if options[:eval], do: Enum.join(args, " "), else: File.read!(hd(args))
    code = if options[:unicode] do
      # input is in unicode
      code
    else
      # input is not in unicode; convert it to unicode
      String.graphemes(code)
      |> Enum.map(fn c -> String.at(@table, hd(to_charlist(c))) end)
      |> Enum.join()
    end
    code = String.replace_trailing(code, "\n", "")
String
    {result, _leftover} = eval(code)
    if !options[:silent] do
      if options[:literal] do
        IO.puts result
      else
        IO.inspect result
      end
    end
  end

  def eval(code) do
    cond do
      code == "" -> {get_input(), ""}
      is_digits(code) ->
        {result, leftover} = Enum.split_while(to_charlist(code), fn char -> char >= 48 and char <= 57 end)
        {String.to_integer(to_string(result)), to_string(leftover)}
      is_quotes(code) ->
        unprefixed = String.replace_prefix(code, ~s/"/, "")
        [result, leftover] = String.split(unprefixed, ~s/"/, parts: 2)
        {result, leftover}
      true ->
        {fun_name, args} = String.next_grapheme(code)
        debug fun_name, "fun_name"
        debug args, "args"
        fun = %{
          " " => fn x -> x end,
          "#" => fn x -> fn -> x end end,
          "$" => fn x -> x.() end,
          "Ȧ" => fn x, y -> to_string(x) <> to_string(y) end,
          "Ḃ" => fn x, y -> [x, y] end,
          "Ċ" => fn -> get_input() end,
          "Ḋ" => fn x -> to_float(x) + 1 end,
          "Ė" => fn x, y -> String.to_integer(to_string(x), to_integer(y)) end,
          "Ḟ" => fn x, y -> Integer.to_string(to_integer(x), to_integer(y)) end,
          "Ġ" => fn x ->
            {_, result} = String.next_grapheme(to_string(x))
            result
          end,
          "Ḣ" => fn x -> 0..to_integer(x) end,
          "İ" => fn x -> 1..to_integer(x) end,
          "J̇" => fn x, y -> to_integer(x)..to_integer(y) end,
          "=" => fn x, y -> x == y end,
          "²" => fn x -> to_float(x)*to_float(x) end,
          "√" => fn x -> :math.sqrt(to_float(x)) end,
          "≠" => fn x, y -> x != y end,
          "½" => fn -> 1/2 end
        }[fun_name]
        debug((case get_arity(fun) do
          2 ->
            {left_eval, left_leftover} = eval(args)
            {right_eval, right_leftover} = eval(left_leftover)
            {fun.(left_eval, right_eval), right_leftover}
          1 ->
            {eval, leftover} = eval(args)
            {fun.(eval), leftover}
          0 -> {fun.(), args}
        end), "result")
    end
  end

  defp get_arity(fun) do
    :erlang.fun_info(fun)[:arity]
  end
  # defp split(code) do
  #   code = to_charlist(code)
  #   [first | rest] = code
  #   cond do
  #     is_digit(first) -> {0, elem(Enum.split_while(code, &is_digit/1), 0)}
  #     is_quote(first) -> {0, [first | Enum.split_while(rest, fn x -> !is_quote(x) end)]}
  #     true -> {first, rest}
  #   end
  # end
  defp is_digits(str) when byte_size(str) > 0, do: length(elem(Enum.split_while(to_charlist(str), fn char -> char >= 48 and char <= 57 end), 0)) > 0
  defp is_digits(_str), do: false
  defp is_quotes(~s/"/ <> str) when byte_size(str) > 0, do: String.contains?(str, ~s/"/)
  defp is_quotes(_str), do: false

  defp get_input(), do: convert(String.replace_trailing(IO.gets(""), "\n", ""))

  defp convert(string) do
    try do
      {value, []} = Code.eval_string(string)
      value
    rescue
      _ -> string
    end
  end

  defp to_integer(x) when is_integer(x), do: x
  defp to_integer(x) when is_float(x), do: round(x)
  defp to_integer(x) when is_binary(x), do: String.to_integer(x)

  defp to_float(x) when is_integer(x), do: to_float(Integer.to_string(x))
  defp to_float(x) when is_binary(x), do: String.to_integer(x)

  def debug(msg, label \\ nil) do
    if Application.get_env(:catholicon, :debug) do
      IO.inspect(msg, label: label, charlists: :as_lists)
    end
    msg
  end
end
