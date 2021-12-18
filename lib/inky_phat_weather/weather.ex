defmodule InkyPhatWeather.Weather do
  @moduledoc false

  require Logger

  @weather_url "https://wttr.in/?format=j1"
  @weather_keys [
    "FeelsLikeC",
    "FeelsLikeF",
    "humidity",
    "localObsDateTime",
    "temp_C",
    "temp_F",
    "weatherDesc"
  ]

  def get_current_weather() do
    fetch_current_weather!()
  rescue
    e ->
      Logger.error(inspect(e))
      nil
  end

  def fetch_current_weather!() do
    %HTTPoison.Response{status_code: 200, body: body} = HTTPoison.get!(@weather_url)
    [current_weather] = body |> Jason.decode!() |> Access.fetch!("current_condition")

    current_weather
    |> Map.take(@weather_keys)
    |> Map.new(fn
      {k, [%{"value" => v}]} -> {k, v}
      kv -> kv
    end)
  end

  # Some possible weather descriptions:
  # https://github.com/chubin/wttr.in/blob/master/lib/constants.py
  def get_icon_name(weather_desc) do
    cond do
      String.match?(weather_desc, ~r/sun|clear/i) -> "sun"
      String.match?(weather_desc, ~r/cloud|overcast/i) -> "cloud"
      String.match?(weather_desc, ~r/thunder/i) -> "storm"
      String.match?(weather_desc, ~r/snow|sleet/i) -> "snow"
      String.match?(weather_desc, ~r/rain|shower/i) -> "rain"
      true -> nil
    end
  end
end
