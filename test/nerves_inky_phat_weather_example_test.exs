defmodule HelloNervesInkyPhatWeatherTest do
  use ExUnit.Case
  doctest HelloNervesInkyPhatWeather

  test "greets the world" do
    assert HelloNervesInkyPhatWeather.hello() == :world
  end
end
