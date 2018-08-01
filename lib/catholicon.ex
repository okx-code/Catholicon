defmodule Catholicon do
  @table "ȦḂĊḊĖḞĠḢİJ̇\nK̇L̇ṀṄȮṖQ̇ṘṠṪU̇V̇ẆẊẎŻȧḃċḋė !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~ḟġḣi̇j̇k̇l̇ṁṅȯṗq̇ṙṡṫu̇v̇ẇẋẏżẠḄC̣ḌẸF̣G̣ḤỊJ̣ḲḶṂṆỌP̣Q̣ṚṢṬỤṾẈX̣ỴẒạḅc̣ḍẹf̣g̣ḥịj̣ḳḷṃṇọp̣q̣ṛṣṭụṿẉx̣ỵẓÅB̊C̊D̊E̊F̊G̊H̊I̊J̊K̊L̊M̊N̊O̊P̊Q̊R̊S̊T̊ŮV̊W̊X̊Y̊Z̊åb̊c̊d̊e̊f̊g̊h̊i̊j̊k̊l̊m̊n̊o̊p̊q̊r̊s̊t̊ův̊ẘx̊ẙz̊²√≠½"

  def main(args) do
    Variables.start_link()

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
    {result, _leftover} = eval(code)
    if !options[:silent] do
      if options[:literal] do
        IO.puts result
      else
        IO.inspect result, charlists: :as_lists
      end
    end
  end

  def eval(code, fallback_fun \\ &get_input/0) do
    cond do
      code == "" -> {fallback_fun.(), ""}
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
        {type, fun} = %{
          "Ȧ" => {:normal, fn x, y -> to_string(x) <> to_string(y) end},
          "Ḃ" => {:normal, fn x, y -> [x, y] end},
          "Ċ" => {:normal, fn -> get_input() end},
          "Ḋ" => {:normal, fn x -> to_float(x) + 1 end},
          "Ė" => {:normal, fn x, y -> String.to_integer(to_string(x), to_integer(y)) end},
          "Ḟ" => {:normal, fn x, y -> Integer.to_string(to_integer(x), to_integer(y)) end},
          "Ġ" => {:normal, fn x ->
            {_, result} = String.next_grapheme(to_string(x))
            result
          end},
          "Ḣ" => {:normal, fn x -> 0..to_integer(x) end},
          "İ" => {:normal, fn x -> 1..to_integer(x) end},
          "J̇" => {:normal, fn x, y -> to_integer(x)..to_integer(y) end},
          "K̇" => {:normal, fn x -> Enum.random(x) end},
          "L̇" => {:normal, fn x -> Integer.digits(to_integer(x)) end},
          "Ṁ" => {:normal, fn x -> Integer.undigits(x) end},
          "Ṅ" => {:normal, fn x -> Enum.sum(x) end},
          "Ȯ" => {:normal, fn x -> Enum.reduce(x, &*/2)}

          "A" => {:normal, fn x -> Variables.put("A", x) end},
          "a" => {:normal, fn -> Variables.get("A") end},

          " " => {:normal, fn x -> x end},
          "!" => {:escape, fn x -> Loop.while_unchanging(fn acc -> eval_value(x, acc) end, &get_input/0) end},
          "#" => {:normal, fn x -> fn -> x end end},
          "$" => {:normal, fn x -> x.() end},
          "&" => {:escape, fn x -> fn -> eval_value(x) end end},
          "%" => {:normal, &vectorise(&1, &2, fn a, b -> rem(a, b) end)},
          "'" => {:escape, fn x -> x end},
          # ()
          "*" => {:normal, &vectorise(&1, &2, fn a, b -> a * b end)},
          "+" => {:normal, &vectorise(&1, &2, fn a, b -> a + b end)},
          "," => {:normal, fn x -> IO.puts(x); x end},
          "-" => {:normal, &vectorise(&1, &2, fn a, b -> a - b end)},
          "." => {:normal, fn x -> IO.write(x); x end},
          "/" => {:normal, &vectorise(&1, &2, fn a, b -> a / b end)},
          ":" => {:normal, fn x, y -> x ++ y end},
          ";" => {:normal, fn x, y -> x -- y end},
          "<" => {:normal, &vectorise(&1, &2, fn a, b -> a < b end)},
          "=" => {:normal, fn x, y -> x == y end},
          ">" => {:normal, &vectorise(&1, &2, fn a, b -> a > b end)},
          # ?A-Z[\]^_`a-z{|}
          "²" => {:normal, fn x -> to_float(x)*to_float(x) end},
          "√" => {:normal, fn x -> :math.sqrt(to_float(x)) end},
          "≠" => {:normal, fn x, y -> x != y end},
          "½" => {:normal, fn -> 1/2 end}
        }[fun_name]
        debug((case get_arity(fun) do
          2 ->
            {left_eval, left_leftover} = do_eval(:normal, args, fallback_fun)
            {right_eval, right_leftover} = do_eval(type, left_leftover, fallback_fun)
            {fun.(left_eval, right_eval), right_leftover}
          1 ->
            {eval, leftover} = do_eval(type, args, fallback_fun)
            {fun.(eval), leftover}
          0 -> {fun.(), args}
        end), "#{fun_name} #{args}")
    end
  end

  defp do_eval(:normal, args, fallback_fun), do: eval(args, fallback_fun)
  defp do_eval(:escape, args, _fallback_fun) do
    split = String.split(args, "~")
    [tl | rest] = Enum.reverse(split)
    {Enum.join(rest, "~"), tl}
  end

  defp eval_value(args, fallback_fun \\ &get_input/0) do
    {value, _leftover} = eval(args, fallback_fun)
    value
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

  defp to_float(x) when is_float(x), do: x
  defp to_float(x) when is_integer(x), do: to_float(Integer.to_string(x))
  defp to_float(x) when is_binary(x), do: String.to_integer(x)

  @doc """
  Vectorises x and y onto fun. x and y may be an object or a list of object,
  but the fun must take two objects and output one.
  """
  def vectorise(x, y, fun)
  def vectorise(x, y, fun) when is_list(x) and is_list(y), do: Enum.map(Enum.zip(x, y), fn {x, y} -> fun.(x, y) end)
  def vectorise(x, y, fun) when is_list(x) and not(is_list(y)), do: Enum.map(x, &fun.(&1, y))
  def vectorise(x, y, fun) when not(is_list(x)) and is_list(y), do: Enum.map(y, &fun.(x, &1))
  def vectorise(x, y, fun) when not(is_list(x)) and not(is_list(y)), do: fun.(x, y)


  def debug(msg, label \\ nil) do
    if Application.get_env(:catholicon, :debug) do
      IO.inspect(:stderr, msg, label: label, charlists: :as_lists)
    end
    msg
  end
end
