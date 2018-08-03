defmodule Catholicon do
  @table "ȦḂĊḊĖḞĠḢİJ̇\nK̇L̇ṀṄȮṖQ̇ṘṠṪU̇V̇ẆẊẎŻȧḃċḋė !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~ḟġḣi̇j̇k̇l̇ṁṅȯṗq̇ṙṡṫu̇v̇ẇẋẏżẠḄC̣ḌẸF̣G̣ḤỊJ̣ḲḶṂṆỌP̣Q̣ṚṢṬỤṾẈX̣ỴẒạḅc̣ḍẹf̣g̣ḥịj̣ḳḷṃṇọp̣q̣ṛṣṭụṿẉx̣ỵẓÅB̊C̊D̊E̊F̊G̊H̊I̊J̊K̊L̊M̊N̊O̊P̊Q̊R̊S̊T̊ŮV̊W̊X̊Y̊Z̊åb̊c̊d̊e̊f̊g̊h̊i̊j̊k̊l̊m̊n̊o̊p̊q̊r̊s̊t̊ův̊ẘx̊ẙz̊²√≠½"

  def main(args) do
    Variables.start_link()
    Input.start_link()

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

  def eval(code, fallback_fun \\ &Input.get_input/0) do
    cond do
      code == "" -> {fallback_fun.(), ""}
      is_digits(code) ->
        {result, leftover} = Enum.split_while(to_charlist(code), fn char -> char >= 48 and char <= 57 end)
        {Variables.put("number", String.to_integer(to_string(result))), to_string(leftover)}
      is_quotes(code) ->
        unprefixed = String.replace_prefix(code, ~s/"/, "")
        [result, leftover] = String.split(unprefixed, ~s/"/, parts: 2)
        {result, leftover}
      true ->
        {fun_name, args} = String.next_grapheme(code)
        debug fun_name, "fun_name"
        debug args, "args"
        {type, fun} = %{
          "Ȧ" => {:normal, &vectorise(to_string(&1), to_string(&2), fn a, b -> a <> b end)},
          "Ḃ" => {:normal, fn x, y -> [x, y] end},
          "Ċ" => {:normal, fn -> Input.get_input() end},
          "Ḋ" => {:normal, &vectorise(to_float(&1), fn a -> a + 1 end)},
          "Ė" => {:normal, &vectorise(to_string(&1), to_integer(&2), fn a, b -> String.to_integer(a, b) end)},
          "Ḟ" => {:normal, &vectorise(to_integer(&1), to_integer(&2), fn a, b -> Integer.to_string(a, b) end)},
          "Ġ" => {:normal, &vectorise(to_string(&1), fn a ->
            {_, result} = String.next_grapheme(a)
            result
          end)},
          "Ḣ" => {:normal, fn x -> 0..to_integer(x) end},
          "İ" => {:normal, fn x -> 1..to_integer(x) end},
          "J̇" => {:normal, fn x, y -> to_integer(x)..to_integer(y) end},
          "K̇" => {:normal, fn x -> Enum.random(to_list(x)) end},
          "L̇" => {:normal, fn x -> Integer.digits(to_integer(x)) end},
          "Ṁ" => {:normal, fn x -> Integer.undigits(to_list(x)) end},
          "Ṅ" => {:normal, &Enum.reduce(to_list(&1), fn a, b -> to_float(a)+to_float(b) end)},
          "Ȯ" => {:normal, &Enum.reduce(to_list(&1), fn a, b -> to_float(a)*to_float(b) end)},
          "Ṗ" => {:normal, &vectorise(to_string(&1), fn a -> String.to_integer(a, 2) end)},
          "Q̇" => {:normal, &vectorise(to_integer(&1), fn a -> Integer.to_string(a, 2) end)},
          "Ṙ" => {:normal, &vectorise(to_integer(&1), fn a -> rem(a, 2) == 0 end)},
          "Ṡ" => {:normal, &vectorise(to_integer(&1), fn a -> rem(a, 2) == 1 end)},
          "Ṫ" => {:normal, &vectorise(to_float(&1), fn a -> a - 1 end)},
          "U̇" => {:normal, &vectorise(to_integer(&1), fn a ->
            Integer.to_string(a, 2)
            |> to_integer()
            |> Integer.digits()
            |> Enum.sum()
          end)},
          "V̇" => {:normal, &vectorise(to_integer(&1), to_integer(&1), fn a, b -> Integer.gcd(a, b) end)},
          "Ẇ" => {:normal, &vectorise(to_float(&1), fn a -> abs(a) end)},
          "Ẋ" => {:normal, &vectorise(to_float_strict(&1), fn a -> Kernel.trunc(Float.ceil(a)) end)},
          "Ẏ" => {:normal, &vectorise(to_float_strict(&1), fn a -> Kernel.trunc(Float.floor(a)) end)},
          "Ż" => {:normal, &vectorise(to_float_strict(&1), fn a -> round(a) end)},
          "ȧ" => {:normal, &vectorise(to_string(&1), fn a -> String.upcase(a) end)},
          "ḃ" => {:normal, &vectorise(to_string(&1), fn a -> String.downcase(a) end)},
          "ċ" => {:normal, &vectorise(to_string(&1), fn a -> String.trim(a) end)},
          "ḋ" => {:normal, &vectorise(to_float_strict(&1), fn a ->
            {n, d} = Float.ratio(a)
            gcd = Integer.gcd(n, d)
            "#{trunc(n / gcd)}/#{trunc(d / gcd)}"
          end)},
          "ė" => {:normal, &vectorise(to_string(&1), fn a ->
            [n, d] = String.split(a, "/")
            to_float(n) / to_float(d)
          end)},

          "A" => {:normal, fn x -> Variables.put("A", x) end},
          "B" => {:normal, fn -> Variables.get("A") end},
          "C" => {:normal, fn -> Variables.get("number") end},
          "D" => {:normal, fn -> Variables.get("loop") end},
          "E" => {:normal, fn -> 10 end},
          "F" => {:normal, fn -> 100 end},
          "G" => {:normal, fn -> 1000 end},
          "a" => {:normal, &vectorise(to_float(&1), fn a -> 1 - a end)},
          "b" => {:normal, &:rand.uniform/0},
          "c" => {:normal, &:rand.normal/0},
          "d" => {:normal, &vectorise(to_string(&1), fn a -> :string.is_empty(a) end)},
          "e" => {:normal, fn x -> convert(to_string(x)) end},
          " " => {:normal, fn x -> x end},
          "!" => {:escape, fn x -> Loop.while_unchanging(fn acc -> eval_value(x, acc) end, &Input.get_input/0) end},
          "#" => {:normal, fn x -> fn -> x end end},
          "$" => {:normal, fn x -> x.() end},
          "&" => {:escape, fn x -> fn -> eval_value(x) end end},
          "%" => {:normal, &vectorise(to_integer(&1), to_integer(&2), fn a, b -> rem(a, b) end)},
          "'" => {:escape, fn x -> x end},
          # ()
          "*" => {:normal, &vectorise(to_float(&1), to_float(&2), fn a, b -> a * b end)},
          "+" => {:normal, &vectorise(to_float(&1), to_float(&2), fn a, b -> a + b end)},
          "," => {:normal, fn x -> IO.puts(x); x end},
          "-" => {:normal, &vectorise(to_float(&1), to_float(&2), fn a, b -> a - b end)},
          "." => {:normal, fn x -> IO.write(x); x end},
          "/" => {:normal, &vectorise(to_float(&1), to_float(&2), fn a, b -> a / b end)},
          ":" => {:normal, fn x, y -> to_list(x) ++ to_list(y) end},
          ";" => {:normal, fn x, y -> to_list(x) -- to_list(y) end},
          "<" => {:normal, &vectorise(to_float(&1), to_float(&2), fn a, b -> a < b end)},
          "=" => {:normal, &vectorise(&1, &2, fn a, b -> a == b end)},
          ">" => {:normal, &vectorise(to_float(&1), to_float(&2), fn a, b -> a > b end)},
          "?" => {:two_char, fn x -> x end},
          "_" => {:two_char, &vectorise(&2, fn a -> TwoChar.get_monad(&1, a) end)},
          "`" => {:two_char, &TwoChar.get_nilad/1},
          "{" => {:normal, &vectorise(to_float(&1), to_float(&2), fn a, b -> a <= b end)},
          "|" => {:normal, &vectorise(&1, &2, fn a, b -> a === b end)},
          "}" => {:normal, &vectorise(to_float(&1), to_float(&2), fn a, b -> a >= b end)},
          # ?A-Z[\]^_`a-z{|}
          "ḟ" => {:normal, &vectorise(to_string(&1), to_string(&2), fn a, b -> String.split(a, b) end)},
          "ġ" => {:normal, &vectorise(to_string(&1), to_string(&2), fn a, b -> count_substring(a, b) end)},
          "ḣ" => {:normal, &vectorise(to_string(&1), to_integer(&2), fn a, b -> String.at(a, rem(b, String.length(a))) end)},
          "i̇" => {:normal, fn x -> length(to_list(x)) end},
          "j̇" => {:escape, fn x, y -> Loop.decompose(to_float(x), fn value -> eval_value(y, fn -> value end) end) end},
          "k̇" => {:normal, &vectorise(to_float(&1), fn a -> a == round(a) end)},
          "l̇" => {:escape, fn x, y -> Loop.map(to_list(x), fn value -> eval_value(y, fn -> value end) end) end},
          "ṁ" => {:normal, &vectorise(to_string(&1), to_integer(&2), fn a, b -> String.pad_leading(a, b) end)},
          "ṅ" => {:normal, &vectorise(to_string(&1), to_integer(&2), fn a, b -> String.pad_trailing(a, b) end)},
          "ȯ" => {:normal, &vectorise(to_float(&1), fn a -> factorial(a) end)},
          "ṗ" => {:normal, &vectorise(to_float(&1), to_float(&2), fn a, b -> max(a, b) end)},
          "q̇" => {:normal, &vectorise(to_float(&1), to_float(&2), fn a, b -> min(a, b) end)},
          "ṙ" => {:normal, &vectorise(to_float(&1), to_float(&2), fn a, b -> :math.pow(a, b) end)},
          "ṡ" => {:normal, &vectorise(to_float(&1), fn a -> trunc(:math.sqrt(a)) end)},
          "ṫ" => {:normal, &vectorise(to_integer(&1), to_integer(&2), fn a, b -> lcm(a, b) end)},
          "u̇" => {:normal, &vectorise(to_string(&1), fn a -> Base.decode16!(a, case: :mixed) end)},
          "v̇" => {:normal, &vectorise(to_string(&1), fn a -> Base.encode16(a) end)},
          "ẇ" => {:normal, &vectorise(to_string(&1), fn a -> Base.decode32!(a, case: :mixed) end)},
          "ẋ" => {:normal, &vectorise(to_string(&1), fn a -> Base.encode32(a) end)},
          "ẏ" => {:normal, &vectorise(to_string(&1), fn a -> Base.decode32!(a, case: :mixed) end)},
          "ż" => {:normal, &vectorise(to_string(&1), fn a -> Base.encode64(a) end)},
          "Ạ" => {:normal, &vectorise(to_float(&1), fn a -> a / 2 end)},
          "Ḅ" => {:normal, &vectorise(to_float(&1), fn a -> a * 2 end)},
          "C̣" => {:normal, fn x, y -> vectorise(to_integer(x), fn a -> Enum.at(y, a))}
          "²" => {:normal, &vectorise(to_float(&1), fn a -> a*a end)},
          "√" => {:normal, &vectorise(to_float(&1), fn a -> :math.sqrt(a) end)},
          "≠" => {:normal, &vectorise(&1, &2, fn a, b -> a != b end)},
          "½" => {:normal, fn -> 1/2 end}
        }[fun_name]
        debug((case get_arity(fun) do
          2 ->
            if type == :two_char do
              {char, rest} = String.next_grapheme(args)
              {eval, leftover} = eval(rest, fallback_fun)
              {fun.(char, eval), leftover}
            else
              {left_eval, left_leftover} = do_eval(:normal, args, fallback_fun)
              {right_eval, right_leftover} = do_eval(type, left_leftover, fallback_fun)
              {fun.(left_eval, right_eval), right_leftover}
            end
          1 ->
            {eval, leftover} = do_eval(type, args, fallback_fun)
            {fun.(eval), leftover}
          0 -> {fun.(), args}
        end), "#{fun_name} #{args}")
    end
  end

  defp do_eval(:normal, args, fallback_fun), do: eval(args, fallback_fun)
  defp do_eval(:two_char, args, _fallback_fun), do: String.next_grapheme(args)
  defp do_eval(:escape, args, _fallback_fun) do
    split = String.split(args, "~")
    if length(split) == 1 do
      {args, ""}
    else
      [tl | rest] = Enum.reverse(split)
      {Enum.join(rest, "~"), tl}
    end
  end

  defp eval_value(args, fallback_fun \\ &Input.get_input/0) do
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

  # defp get_input(), do: convert(String.replace_trailing(IO.gets(""), "\n", ""))

  def convert(string) do
    try do
      {value, []} = Code.eval_string(string)
      value
    rescue
      _ -> string
    end
  end

  def to_integer(x) when is_integer(x), do: x
  def to_integer(x) when is_float(x), do: round(x)
  def to_integer(x) when is_binary(x), do: String.to_integer(x)
  def to_integer(_), do: :error

  def to_float_strict(x) when is_float(x), do: x
  def to_float_strict(x) when is_integer(x), do: to_float(Integer.to_string(x))
  def to_float_strict(x) when is_binary(x), do: String.to_float(x)
  def to_float_strict(_), do: :error

  def to_float(x) when is_float(x), do: x
  def to_float(x) when is_integer(x), do: x
  def to_float(x) when is_binary(x) do
    case Integer.parse(x) do
      {value, ""} -> value
      _ -> do_float_parse(x)
    end
  end
  def to_float(_), do: :error

  defp do_float_parse(x) do
    {x, ""} = Float.parse(x)
    x
  end

  def to_list(x) when is_list(x), do: x
  def to_list(x) when is_binary(x), do: String.graphemes(x)
  def to_list(x) when is_integer(x), do: Integer.digits(x)
  def to_list(_), do: :error

  def count_substring(_, ""), do: 0
  def count_substring(str, sub), do: length(String.split(str, sub)) - 1

  def factorial(n), do: do_factorial(n, 1)
  defp do_factorial(0, f), do: f
  defp do_factorial(n, f), do: do_factorial(n-1, f*n)

  def lcm(0, 0), do: 0
  def lcm(a, b), do: abs(Kernel.div(a * b, Integer.gcd(a, b)))

  @doc """
  Vectorises x and y onto fun. x and y may be an object or a list of object,
  but the fun must take two objects and output one.
  """
  def vectorise(x, y, fun)
  def vectorise(x, y, fun) when is_list(x) and is_list(y), do: Enum.map(Enum.zip(x, y), fn {x, y} -> fun.(x, y) end)
  def vectorise(x, y, fun) when is_list(x) and not(is_list(y)), do: Enum.map(x, &fun.(&1, y))
  def vectorise(x, y, fun) when not(is_list(x)) and is_list(y), do: Enum.map(y, &fun.(x, &1))
  def vectorise(x, y, fun) when not(is_list(x)) and not(is_list(y)), do: fun.(x, y)

  @doc """
  Vectorises x onto fun. x may be an object or a list of object,
  but the fun must take one object and output one.
  """
  def vectorise(x, fun)
  def vectorise(x, fun) when is_list(x), do: Enum.map(x, fun)
  def vectorise(x, fun) when not is_list(x), do: fun.(x)

  def debug(msg, label \\ nil) do
    if Application.get_env(:catholicon, :debug) do
      IO.inspect(:stderr, msg, label: label, charlists: :as_lists)
    end
    msg
  end
end
