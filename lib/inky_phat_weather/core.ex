defmodule InkyPhatWeather.Core do
  @moduledoc false

  defstruct ~w[chisel_font inky_pid last_weather icons]a

  @icon_names ~w[cloud rain snow storm sun wind]
  @default_icons_dir "/my_app/icons"
  @default_icon_offset {200, 80}

  # Build a map of icon name to Inky-compatible pixels based on icon pixel data
  def init_icons!(opts \\ []) do
    @icon_names
    |> Enum.map(fn icon_name -> init_icon!(icon_name, opts) end)
    |> Enum.into(%{})
  end

  defp init_icon!(icon_name, opts) do
    {icon_offset_x, icon_offset_y} = Access.get(opts, :icon_offset, @default_icon_offset)
    icons_dir = Access.get(opts, :icons_dir, @default_icons_dir)

    {
      icon_name,
      File.read!("#{icons_dir}/#{icon_name}.json")
      |> Jason.decode!()
      |> Enum.with_index()
      |> Enum.flat_map(fn {row, index_y} ->
        row
        |> Enum.with_index()
        |> Enum.map(fn
          {0, index_x} -> {{index_x + icon_offset_x, index_y + icon_offset_y}, :white}
          {_, index_x} -> {{index_x + icon_offset_x, index_y + icon_offset_y}, :black}
        end)
      end)
      |> Enum.into(%{})
    }
  end

  def set_current_time_pixels(state) do
    NaiveDateTime.local_now()
    |> Calendar.strftime("%Y-%m-%d %I:%M %p")
    |> print_text({10, 10}, :black, [size_x: 2, size_y: 3], state)
  end

  def maybe_set_weather_pixels(%{last_weather: nil} = state), do: state

  def maybe_set_weather_pixels(%{last_weather: last_weather} = state) do
    """
    #{last_weather["weatherDesc"]}
    Feels like #{last_weather["FeelsLikeF"]}°
    """
    |> print_text({10, 64}, :black, [size_x: 2, size_y: 2], state)

    state
  end

  def set_icon(state) do
    icon_name = InkyPhatWeather.Weather.get_icon_name(state.last_weather["weatherDesc"])

    if icon_name do
      Inky.set_pixels(state.inky_pid, Access.fetch!(state.icons, icon_name), push: :skip)
    end
  end

  def clear_pixels(state) do
    Inky.set_pixels(state.inky_pid, fn _x, _y, _w, _h, _pixels -> :white end, push: :skip)
  end

  def print_text(text, {x, y}, color, opts, state) do
    put_pixels_fun = fn x, y ->
      Inky.set_pixels(state.inky_pid, %{{x, y} => color}, push: :skip)
    end

    Chisel.Renderer.draw_text(text, x, y, state.chisel_font, put_pixels_fun, opts)
  end

  def push_pixels(state) do
    Inky.set_pixels(state.inky_pid, %{}, push: :await)
  end
end
