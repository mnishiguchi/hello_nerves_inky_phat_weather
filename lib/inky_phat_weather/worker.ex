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
    {:ok, %InkyPhatWeather.Display{}, {:continue, :load_font}}
  end

  @impl GenServer
  def handle_continue(:load_font, state) do
    chisel_font = InkyPhatWeather.Font.load!("6x13")
    Logger.info("#{@log_label}: Font loaded")

    {:noreply, %{state | chisel_font: chisel_font}, {:continue, :init_icons}}
  end

  @impl GenServer
  def handle_continue(:init_icons, state) do
    InkyPhatWeather.Icons.start_link()
    Logger.info("#{@log_label}: Icons initialized")

    {:noreply, state, {:continue, :start_inky}}
  end

  @impl GenServer
  def handle_continue(:start_inky, state) do
    unless state.chisel_font, do: raise("Font is not yet loaded")

    {:ok, inky_pid} = Inky.start_link(:phat_ssd1608, :black)
    Logger.info("#{@log_label}: Started Inky server")

    send(self(), :tick)
    Logger.info("#{@log_label}: Started ticking")

    {:noreply, %{state | inky_pid: inky_pid}}
  end

  @impl GenServer
  def handle_info(:tick, state) do
    Process.send_after(self(), :tick, 1000)

    # Refresh pixels only when the second is zero
    if DateTime.utc_now().second == 0 do
      {:noreply, InkyPhatWeather.Display.refresh_pixels!(state)}
    else
      {:noreply, state}
    end
  end
end
