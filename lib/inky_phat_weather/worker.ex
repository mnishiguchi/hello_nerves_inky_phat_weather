defmodule InkyPhatWeather.Worker do
  @moduledoc false

  use GenServer, restart: :transient

  require Logger

  @log_label "InkyPhatWeather"

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl GenServer
  def init(_opts) do
    {:ok, %InkyPhatWeather.Core{}, {:continue, :init_icons}}
  end

  @impl GenServer
  def handle_continue(:init_icons, state) do
    icons = InkyPhatWeather.Core.init_icons!()
    Logger.info("#{@log_label}: Icons initialized")

    {:noreply, %{state | icons: icons}, {:continue, :load_font}}
  end

  @impl GenServer
  def handle_continue(:load_font, state) do
    chisel_font = InkyPhatWeather.Font.load!("6x13")
    Logger.info("#{@log_label}: Font loaded")

    {:noreply, %{state | chisel_font: chisel_font}, {:continue, :start_inky}}
  end

  @impl GenServer
  def handle_continue(:start_inky, state) do
    unless state.chisel_font, do: raise("Font is not yet loaded")

    {:ok, inky_pid} = Inky.start_link(:phat_ssd1608, :black)
    Logger.info("#{@log_label}: Started Inky server")

    wait_until_zero_second()

    send(self(), :tick)
    Logger.info("#{@log_label}: Started ticking")

    {:noreply, %{state | inky_pid: inky_pid}}
  end

  @impl GenServer
  def handle_info(:tick, state) do
    # Tick every second
    Process.send_after(self(), :tick, :timer.seconds(1))

    # Refresh pixels only when the second is zero
    if DateTime.utc_now().second == 0 do
      state = state |> maybe_fetch_and_assign_weather()
      InkyPhatWeather.Core.refresh_pixels!(state)

      {:noreply, state}
    else
      {:noreply, state}
    end
  end

  defp maybe_fetch_and_assign_weather(state) do
    # Fetch every 30 minutes
    if is_nil(state.last_weather) or DateTime.utc_now().minute in [0, 30] do
      last_weather = InkyPhatWeather.Weather.fetch_current_weather!()
      %{state | last_weather: last_weather}
    else
      state
    end
  end

  defp wait_until_zero_second() do
    if DateTime.utc_now().second == 0 do
      Logger.info("#{@log_label}: Zero second")
      :ok
    else
      Process.sleep(:timer.seconds(1))
      wait_until_zero_second()
    end
  end
end
