defmodule TwitchApiTest do
  use ExUnit.Case
  doctest TwitchApi

  test "greets the world" do
    assert TwitchApi.hello() == :world
  end
end
