defmodule InkyPhatWeather.Weather do
  @moduledoc false

  require Logger

  @log_label "InkyPhatWeather.Weather"
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
      Logger.error("#{@log_label}: #{inspect(e)}")
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
end
