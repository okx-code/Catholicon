defmodule TwoChar do
  import Catholicon

  def get_nilad(char)  do
    %{
      "Ȧ" => 10,
      "Ḃ" => 100,
      "Ċ" => 1000,
      "Ḋ" => "abcdefghijklmnopqrstuvwxyz",
      "Ė" => :math.pi(),
      "Ḟ" => 1.618033988749895,
      "Ġ" => :math.pi() * 2,
    }[char]
  end

  def get_monad(char, arg) do
    %{
      "Ȧ" => fn x -> to_float(x) * 10 end,
      "Ḃ" => &:math.acos(to_float(&1)),
      "Ċ" => &:math.acosh(to_float(&1)),
      "Ḋ" => &:math.asin(to_float(&1)),
      "Ė" => &:math.asinh(to_float(&1)),
      "Ḟ" => &:math.atan(to_float(&1)),
      "Ġ" => &:math.atanh(to_float(&1)),
      "Ḣ" => &:math.cos(to_float(&1)),
      "İ" => &:math.cosh(to_float(&1)),
      "J̇" => &:math.erf(to_float(&1)),
      "K̇" => &:math.erfc(to_float(&1)),
      "L̇" => &:math.exp(to_float(&1)),
      "Ṁ" => &:math.log(to_float(&1)),
      "Ṅ" => &:math.log10(to_float(&1)),
      "Ȯ" => &:math.log2(to_float(&1)),
      "Ṗ" => &:math.sin(to_float(&1)),
      "Q̇" => &:math.sinh(to_float(&1)),
      "Ṙ" => &:math.tan(to_float(&1)),
      "Ṡ" => &:math.tanh(to_float(&1)),
      "Ṫ" => &String.to_atom(to_string(&1))
    }[char].(arg)
  end
end
