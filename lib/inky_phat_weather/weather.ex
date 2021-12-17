defmodule InkyPhatWeather.Weather do
  @moduledoc false

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

  def fetch_current_weather!() do
    {:ok, {{_, 200, _}, _headers, body}} = :httpc.request(@weather_url)

    body
    |> List.to_string()
    |> Jason.decode!()
    |> Access.fetch!("current_condition")
    |> hd()
    |> Map.take(@weather_keys)
    |> Map.new(fn {k, v} ->
      {k, format_weather_value(v)}
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

  defp format_weather_value([%{"value" => value}]), do: value
  defp format_weather_value(value), do: value
end
