defmodule Catholicon do
  @table "ȦḂĊḊĖḞĠḢİJ̇\nK̇L̇ṀṄȮṖQ̇ṘṠṪU̇V̇ẆẊẎŻȧḃċḋė !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~ḟġḣi̇j̇k̇l̇ṁṅȯṗq̇ṙṡṫu̇v̇ẇẋẏżẠḄC̣ḌẸF̣G̣ḤỊJ̣ḲḶṂṆỌP̣Q̣ṚṢṬỤṾẈX̣ỴẒạḅc̣ḍẹf̣g̣ḥịj̣ḳḷṃṇọp̣q̣ṛṣṭụṿẉx̣ỵẓÅB̊C̊D̊E̊F̊G̊H̊I̊J̊K̊L̊M̊N̊O̊P̊Q̊R̊S̊T̊ŮV̊W̊X̊Y̊Z̊åb̊c̊d̊e̊f̊g̊h̊i̊j̊k̊l̊m̊n̊o̊p̊q̊r̊s̊t̊ův̊ẘx̊ẙz̊²√≠½"

  def main(args) do
    Variables.start_link()
    Variables.put("number", 0)
    Variables.put("loop", 1)
    Variables.put("A", 2)
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
      String.codepoints(code)
      |> Enum.map(fn c -> <<x :: size(8)>> = c; x end)
      |> Enum.map(fn c -> String.at(@table, c) end)
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
      code == "" -> {debug(fallback_fun.(), "fallback"), ""}
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
          "Ȧ" => {:normal, &vectorise(&1, &2, fn a, b -> to_string(a) <> to_string(b) end)},
          "Ḃ" => {:normal, fn x, y -> [x, y] end},
          "Ċ" => {:normal, fn -> Input.get_input() end},
          "Ḋ" => {:normal, &vectorise(&1, fn a -> to_float(a) + 1 end)},
          "Ė" => {:normal, &vectorise(&1, &2, fn a, b -> String.to_integer(to_string(a), to_integer(b)) end)},
          "Ḟ" => {:normal, &vectorise(&1, &2, fn a, b -> Integer.to_string(to_integer(a), to_integer(b)) end)},
          "Ġ" => {:normal, &vectorise(&1, fn a ->
            {_, result} = String.next_grapheme(to_string(a))
            result
          end)},
          "Ḣ" => {:normal, &vectorise(&1, fn a -> Enum.to_list(0..to_integer(a)) end)},
          "İ" => {:normal, &vectorise(&1, fn a -> Enum.to_list(1..to_integer(a)) end)},
          "J̇" => {:normal, fn x, y -> Enum.to_list(to_integer(x)..to_integer(y)) end},
          "K̇" => {:normal, &vectorise_list(&1, fn a -> Enum.random(to_list(a)) end)},
          "L̇" => {:normal, &vectorise(&1, fn a -> Integer.digits(to_integer(a)) end)},
          "Ṁ" => {:normal, fn x -> Integer.undigits(to_list(x)) end},
          "Ṅ" => {:normal, &vectorise_list(&1, fn a -> Enum.reduce(to_list(a), fn a, b -> to_float(a)+to_float(b) end) end)},
          "Ȯ" => {:normal, &vectorise_list(&1, fn a -> Enum.reduce(to_list(a), fn a, b -> to_float(a)*to_float(b) end) end)},
          "Ṗ" => {:normal, &vectorise(&1, fn a -> String.to_integer(to_string(a), 2) end)},
          "Q̇" => {:normal, &vectorise(&1, fn a -> Integer.to_string(to_integer(a), 2) end)},
          "Ṙ" => {:normal, &vectorise(&1, fn a -> rem(to_integer(a), 2) == 0 end)},
          "Ṡ" => {:normal, &vectorise(&1, fn a -> rem(to_integer(a), 2) == 1 end)},
          "Ṫ" => {:normal, &vectorise(&1, fn a -> to_float(a) - 1 end)},
          "U̇" => {:normal, &vectorise(&1, fn a ->
            to_integer(a)
            |> Integer.to_string(2)
            |> to_integer()
            |> Integer.digits()
            |> Enum.sum()
          end)},
          "V̇" => {:normal, &vectorise(&1, &1, fn a, b -> Integer.gcd(to_integer(a), to_integer(b)) end)},
          "Ẇ" => {:normal, &vectorise(&1, fn a -> abs(to_float(a)) end)},
          "Ẋ" => {:normal, &vectorise(&1, fn a -> Kernel.trunc(Float.ceil(to_float_strict(a))) end)},
          "Ẏ" => {:normal, &vectorise(&1, fn a -> Kernel.trunc(Float.floor(to_float_strict(a))) end)},
          "Ż" => {:normal, &vectorise(&1, fn a -> round(to_float(a)) end)},
          "ȧ" => {:normal, &vectorise(&1, fn a -> String.upcase(to_string(a)) end)},
          "ḃ" => {:normal, &vectorise(&1, fn a -> String.downcase(to_string(a)) end)},
          "ċ" => {:normal, &vectorise(&1, fn a -> String.trim(to_string(a)) end)},
          "ḋ" => {:normal, &vectorise(&1, fn a ->
            {n, d} = Float.ratio(to_float_strict(a))
            gcd = Integer.gcd(n, d)
            "#{trunc(n / gcd)}/#{trunc(d / gcd)}"
          end)},
          "ė" => {:normal, &vectorise(&1, fn a ->
            [n, d] = String.split(to_string(a), "/")
            to_float(n) / to_float(d)
          end)},

          "A" => {:normal, fn x -> Variables.put("A", x) end},
          "B" => {:normal, fn -> Variables.get("A") end},
          "C" => {:normal, fn -> Variables.get("number") end},
          "D" => {:normal, fn -> Variables.get("loop") end},
          "E" => {:normal, fn -> 10 end},
          "F" => {:normal, fn -> 100 end},
          "G" => {:normal, fn -> 1000 end},
          "H" => {:normal, fn -> Input.get_input(0) end},
          "a" => {:normal, &vectorise(&1, fn a -> 1 - to_float(a) end)},
          "b" => {:normal, &:rand.uniform/0},
          "c" => {:normal, &:rand.normal/0},
          "d" => {:normal, &vectorise(&1, fn a -> :string.is_empty(to_string(a)) end)},
          "e" => {:normal, fn x -> convert(to_string(x)) end},
          " " => {:normal, fn x -> x end},
          "!" => {:escape, fn x -> Loop.while_unchanging(fn acc -> eval_value(x, acc) end, &Input.get_input/0) end},
          "#" => {:normal, fn x -> fn -> x end end},
          "$" => {:normal, fn x -> x.() end},
          "&" => {:escape, fn x -> fn -> eval_value(x) end end},
          "%" => {:normal, &vectorise(&1, &2, fn a, b -> rem(to_integer(a), to_integer(b)) end)},
          "'" => {:escape, fn x -> x end},
          # ()
          "*" => {:normal, &vectorise(&1, &2, fn a, b -> to_float(a) * to_float(b) end)},
          "+" => {:normal, &vectorise(&1, &2, fn a, b -> to_float(a) + to_float(b) end)},
          "," => {:normal, fn x -> IO.puts(x); x end},
          "-" => {:normal, &vectorise(&1, &2, fn a, b -> to_float(a) - to_float(b) end)},
          "." => {:normal, fn x -> IO.write(x); x end},
          "/" => {:normal, &vectorise(&1, &2, fn a, b -> to_float(a) / to_float(b) end)},
          ":" => {:normal, fn x, y -> to_list(x) ++ to_list(y) end},
          ";" => {:normal, fn x, y -> to_list(x) -- to_list(y) end},
          "<" => {:normal, &vectorise(&1, &2, fn a, b -> to_float(a) < to_float(b) end)},
          "=" => {:normal, &vectorise(&1, &2, fn a, b -> a == b end)},
          ">" => {:normal, &vectorise(&1, &2, fn a, b -> to_float(a) > to_float(b) end)},
          "?" => {:two_char, fn x -> x end},
          "@" => {:escape, fn x -> for c <- Enum.map(String.graphemes(x), &Enum.find_index(String.graphemes(@table), fn a -> a==&1 end)), into: "", do: <<c>> end},
          "_" => {:two_char, &vectorise(&2, fn a -> TwoChar.get_monad(&1, a) end)},
          "`" => {:two_char, &TwoChar.get_nilad/1},
          "{" => {:normal, &vectorise(&1, &2, fn a, b -> to_float(a) <= to_float(b) end)},
          "|" => {:normal, &vectorise(&1, &2, fn a, b -> a === b end)},
          "}" => {:normal, &vectorise(&1, &2, fn a, b -> to_float(a) >= to_float(b) end)},
          # ?A-Z[\]^_`a-z{|}
          "ḟ" => {:normal, &vectorise(&1, &2, fn a, b -> String.split(to_string(a), to_string(b)) end)},
          "ġ" => {:normal, &vectorise(&1, &2, fn a, b -> count_substring(to_string(a), to_string(b)) end)},
          "ḣ" => {:normal, &vectorise(&1, &2, fn a, b -> String.at(to_string(a), rem(to_integer(b), String.length(to_string(a)))) end)},
          "i̇" => {:normal, fn x -> length(to_list(x)) end},
          "j̇" => {:escape, &vectorise(&1, fn a -> Loop.decompose(to_float(a), fn value -> eval_value(&2, fn -> value end) end) end)},
          "k̇" => {:normal, &vectorise(&1, fn a -> to_float(a) == round(to_float(a)) end)},
          "l̇" => {:escape, fn x, y -> Enum.map(to_list(x), fn value -> eval_value(y, fn -> value end) end) end},
          "ṁ" => {:normal, &vectorise(&1, &2, fn a, b -> String.pad_leading(to_string(a), to_integer(b)) end)},
          "ṅ" => {:normal, &vectorise(&1, &2, fn a, b -> String.pad_trailing(to_string(a), to_integer(b)) end)},
          "ȯ" => {:normal, &vectorise(&1, fn a -> factorial(to_float(a)) end)},
          "ṗ" => {:normal, &vectorise(&1, &2, fn a, b -> max(to_float(a), to_float(b)) end)},
          "q̇" => {:normal, &vectorise(&1, &2, fn a, b -> min(to_float(a), to_float(b)) end)},
          "ṙ" => {:normal, &vectorise(&1, &2, fn a, b -> :math.pow(to_float(a), to_float(b)) end)},
          "ṡ" => {:normal, &vectorise(&1, fn a -> trunc(:math.sqrt(to_float(a))) end)},
          "ṫ" => {:normal, &vectorise(&1, &2, fn a, b -> lcm(to_integer(a), to_integer(b)) end)},
          "u̇" => {:normal, &vectorise(&1, fn a -> Base.decode16!(to_string(a), case: :mixed) end)},
          "v̇" => {:normal, &vectorise(&1, fn a -> Base.encode16(to_string(a)) end)},
          "ẇ" => {:normal, &vectorise(&1, fn a -> Base.decode32!(to_string(a), case: :mixed) end)},
          "ẋ" => {:normal, &vectorise(&1, fn a -> Base.encode32(to_string(a)) end)},
          "ẏ" => {:normal, &vectorise(&1, fn a -> Base.decode32!(to_string(a), case: :mixed) end)},
          "ż" => {:normal, &vectorise(&1, fn a -> Base.encode64(to_string(a)) end)},
          "Ạ" => {:normal, &vectorise(&1, fn a -> to_float(a) / 2 end)},
          "Ḅ" => {:normal, &vectorise(&1, fn a -> to_float(a) * 2 end)},
          "C̣" => {:normal, fn x, y -> vectorise(x, fn a -> Enum.at(y, to_integer(a)) end) end},
          "Ḍ" => {:normal, fn x ->
            group = group_adjacent(to_list(x))
            case x do
              x when is_integer(x) -> Enum.map(group, &Integer.undigits/1)
              x when not is_list(x) -> Enum.map(group, &Enum.join(Enum.map(&1, fn a -> to_string(a) end)))
              _ -> group
            end
          end},
          "Ẹ" => {:normal, &vectorise_list(&1, fn a -> cumulative_sum(to_list(a)) end)},
          "F̣" => {:normal, fn x -> Enum.flat_map(to_list(x), fn a -> a end) end},
          "G̣" => {:escape, fn x, y -> Enum.reduce(x, fn a, b ->
            Variables.put("loop", a)
            eval_value(y, fn -> b end)
          end) end},
          "Ḥ" => {:normal, &vectorise(&1, fn a -> prime_factors(to_integer(a)) end)},
          "Ị" => {:normal, &hd(&1)},
          "J̣" => {:normal, &tl(&1)},
          "²" => {:normal, &vectorise(&1, fn a -> to_float(a)*to_float(a) end)},
          "√" => {:normal, &vectorise(&1, fn a -> :math.sqrt(to_float(a)) end)},
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

  defp do_eval(:normal, "\\" <> args, fallback_fun) do
    {[first, second], leftover} = do_eval(:normal, args, fallback_fun)
    {first, {:two_arg, second, leftover}}
  end
  defp do_eval(_, {:two_arg, second, args}, _) do
    {second, args}
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
  def to_integer(true), do: 1
  def to_integer(false), do: 0
  def to_integer(_), do: :error

  def to_float_strict(x) when is_float(x), do: x
  def to_float_strict(x) when is_integer(x), do: to_float(Integer.to_string(x))
  def to_float_strict(x) when is_binary(x), do: String.to_float(x)
  def to_float_strict(true), do: 1
  def to_float_strict(false), do: 0
  def to_float_strict(_), do: :error

  def to_float(x) when is_float(x), do: x
  def to_float(x) when is_integer(x), do: x
  def to_float(x) when is_binary(x) do
    case Integer.parse(x) do
      {value, ""} -> value
      _ -> do_float_parse(x)
    end
  end
  def to_float(true), do: 1
  def to_float(false), do: 0
  def to_float(_), do: :error

  defp do_float_parse(x) do
    {x, ""} = Float.parse(x)
    x
  end

  def to_list(x) when is_list(x), do: x
  def to_list(x) when is_binary(x), do: String.graphemes(x)
  def to_list(x) when is_integer(x), do: Integer.digits(x)
  def to_list(x) when is_float(x), do: to_list(to_string(x))
  def to_list(_), do: :error

  def to_boolean(x) when x == 1 or x == "1", do: true
  def to_boolean(x) when x == 0 or x == "0", do: false
  def to_boolean(x) when is_number(x) or is_binary(x), do: false
  def to_boolean(x), do: !!x

  def count_substring(_, ""), do: 0
  def count_substring(str, sub), do: length(String.split(str, sub)) - 1

  def factorial(n), do: do_factorial(n, 1)
  defp do_factorial(0, f), do: f
  defp do_factorial(n, f), do: do_factorial(n-1, f*n)

  def group_adjacent(group) do
    Enum.chunk_while(group, [], fn i, chunk ->
      if length(chunk) == 0 or hd(chunk) == i do
        {:cont, chunk ++ [i]}
      else
        {:cont, chunk, [i]}
      end
    end, fn x -> {:cont, x, []} end)
  end

  def lcm(0, 0), do: 0
  def lcm(a, b), do: abs(Kernel.div(a * b, Integer.gcd(a, b)))

  def cumulative_sum(enum) do
    if Enum.all?(enum, &is_list/1) do
      Enum.map(enum, &cumulative_sum/1)
    else
      Enum.scan(enum, &+/2)
    end
  end

  def prime_factors(n), do: do_prime_factors(n, 2, [])
  defp do_prime_factors(n, k, acc) when n < k*k, do: Enum.reverse(acc, [n])
  defp do_prime_factors(n, k, acc) when rem(n, k) == 0, do: do_prime_factors(div(n, k), k, [k | acc])
  defp do_prime_factors(n, k, acc), do: do_prime_factors(n, k+1, acc)

  @doc """
  Vectorises x and y onto fun. x and y may be an object or a list of object,
  but the fun must take two objects and output one.
  """
  def vectorise(x, y, fun)
  def vectorise(x, y, fun) when is_list(x) and is_list(y), do: Enum.map(x, &vectorise(&1, y, fun))
  def vectorise(x, y, fun) when is_list(x) and not(is_list(y)), do: Enum.map(x, &vectorise(&1, y, fun))
  def vectorise(x, y, fun) when not(is_list(x)) and is_list(y), do: Enum.map(y, &vectorise(x, &1, fun))
  def vectorise(x, y, fun) when not(is_list(x)) and not(is_list(y)), do: fun.(x, y)

  @doc """
  Vectorises x onto fun. x may be an object or a list of object,
  but the fun must take one object and output one.
  """
  def vectorise(x, fun)
  def vectorise(x, fun) when is_list(x), do: Enum.map(x, &vectorise(&1, fun))
  def vectorise(x, fun) when not is_list(x), do: fun.(x)

  def vectorise_list(x, fun) do
    if Enum.all?(x, &is_list/1) do
      Enum.map(x, &vectorise_list(&1, fun))
    else
      fun.(x)
    end
  end

  def debug(msg, label \\ nil) do
    if Application.get_env(:catholicon, :debug) do
      IO.inspect(:stderr, msg, label: label, charlists: :as_lists)
    end
    msg
  end
end
