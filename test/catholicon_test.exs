defmodule CatholiconTest do
  use ExUnit.Case
  doctest Catholicon

  test "works" do
    assert Catholicon.main(["abc", "def", "g"]) == "abc def g"
  end
end
