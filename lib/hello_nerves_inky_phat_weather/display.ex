defmodule HelloNervesInkyPhatWeather.Display do
  @moduledoc false

  defstruct ~w[chisel_font inky_pid last_weather]a

  @spec refresh_pixels!(struct()) :: struct()
  def refresh_pixels!(state) do
    state
    |> maybe_fetch_and_assign_weather()
    |> clear_pixels()
    |> buffer_current_time_pixels()
    |> buffer_weather_pixels()
    |> buffer_icon_pixels()
    |> push_pixels()
    |> struct!(last_weather: nil)
  end

  @spec buffer_current_time_pixels(struct()) :: struct()
  defp buffer_current_time_pixels(state) do
    current_time_text()
    |> set_text_pixels({10, 10}, :black, [size_x: 2, size_y: 3], state)
  end

  @spec buffer_weather_pixels(struct()) :: struct()
  defp buffer_weather_pixels(state) do
    weather_template(state)
    |> set_text_pixels({10, 64}, :black, [size_x: 2, size_y: 2], state)
  end

  @spec buffer_icon_pixels(struct()) :: struct()
  defp buffer_icon_pixels(state) do
    case weather_icon(state) do
      nil -> state
      icon -> set_icon_pixels(icon, state)
    end
  end

  ## View

  def weather_template(state) do
    """
    #{weather_description_text(state)}
    #{feels_like_f_text(state)}
    """
  end

  def current_time_text() do
    NaiveDateTime.local_now() |> Calendar.strftime("%Y-%m-%d %I:%M %p")
  end

  def weather_description_text(%{last_weather: last_weather}) do
    if last_weather do
      %{"weatherDesc" => weather_desc} = last_weather
      weather_desc |> String.split(",") |> List.first()
    else
      "-"
    end
  end

  def feels_like_f_text(%{last_weather: last_weather}) do
    if last_weather do
      %{"FeelsLikeF" => feel_like_f} = last_weather
      "Feels like #{feel_like_f}°F"
    else
      "-"
    end
  end

  def weather_icon(%{last_weather: last_weather}) do
    if last_weather do
      %{"weatherDesc" => weather_desc} = last_weather
      icon_name = HelloNervesInkyPhatWeather.Icons.get_weather_icon_name(weather_desc)
      HelloNervesInkyPhatWeather.Icons.get(icon_name)
    else
      nil
    end
  end

  ## Data fetching

  defp maybe_fetch_and_assign_weather(state) do
    # Fetch every 30 minutes
    if is_nil(state.last_weather) or DateTime.utc_now().minute in [0, 30] do
      %{state | last_weather: HelloNervesInkyPhatWeather.Weather.get_current_weather()}
    else
      state
    end
  end

  ## Pixel printing

  defp clear_pixels(state) do
    Inky.set_pixels(state.inky_pid, fn _x, _y, _w, _h, _pixels -> :white end, push: :skip)
    state
  end

  defp set_text_pixels(text, {x, y}, color, opts, state) do
    put_pixels_fun = fn x, y ->
      Inky.set_pixels(state.inky_pid, %{{x, y} => color}, push: :skip)
    end

    Chisel.Renderer.draw_text(text, x, y, state.chisel_font, put_pixels_fun, opts)
    state
  end

  def set_icon_pixels(icon_pixels, state) do
    Inky.set_pixels(state.inky_pid, icon_pixels, push: :skip)
    state
  end

  defp push_pixels(state) do
    Inky.set_pixels(state.inky_pid, %{}, push: :await)
    state
  end
end
