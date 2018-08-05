defmodule TwoChar do
  import Catholicon

  def get_nilad(char)  do
    %{
      "Ȧ" => 16,
      "Ḃ" => 32,
      "Ċ" => 64,
      "Ḋ" => "abcdefghijklmnopqrstuvwxyz",
      "Ė" => :math.pi(),
      "Ḟ" => :math.pi() * 2,
      "Ġ" => 1.618033988749895,
      "Ḣ" => 128,
      "İ" => 255,
      "J̇" => 256,
      "K̇" => 512,
      "L̇" => 1024,
      "Ṁ" => 2048,
      "Ṅ" => 32768,
      "Ȯ" => 65536,
      "Ṗ" => 2147483648,
      "Q̇" => 4294967296,
      "Ṙ" => 9223372036854776000,
      "Ṡ" => 18446744073709552000,
      "Ṫ" => 1/3,
      "U̇" => 1/4,
      "V̇" => 1/5,
      "Ẇ" => 2/3,
      "Ẋ" => 3/4,
      "Ẏ" => 2/5,
      "Ż" => 3/5,
      "ȧ" => 4/5,
      "ḃ" => 16
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
