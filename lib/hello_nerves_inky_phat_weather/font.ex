defmodule HelloNervesInkyPhatWeather.Font do
  @moduledoc """
  The font repository.
  """

  use Agent

  @fonts_dir "/data/fonts"
  @fonts_remote_base_url "https://raw.githubusercontent.com/olikraus/u8g2/master/tools/font/bdf"

  def start_link(_opts \\ []) do
    initial_state = %{}
    Agent.start_link(fn -> initial_state end, name: __MODULE__)
  end

  @doc """
  Loads a font file, converts it to a [Chisel.Font] struct. The result is cached.
  See [olikraus/u8g2] for bdf fonts.

  ## Examples

      Font.load!("5x8.bdf")

  [Chisel.Font]: https://hexdocs.pm/chisel/Chisel.Font.html
  [olikraus/u8g2]: https://github.com/olikraus/u8g2/tree/master/tools/font/bdf
  """
  def load!(bdf_font_name) do
    if not String.ends_with?(bdf_font_name, ".bdf") do
      raise("font name must end with .bdf")
    end

    if not File.exists?(raw_font_file(bdf_font_name)) do
      File.mkdir_p(@fonts_dir)
      :ok = download_raw_font!(bdf_font_name)
    end

    get_or_insert_by(bdf_font_name, &build_chisel_font/1)
  end

  defp get_or_insert_by(font_name, chisel_font_builder) do
    if chisel_font = get_by(font_name) do
      chisel_font
    else
      %Chisel.Font{} = chisel_font = chisel_font_builder.(font_name)
      :ok = save(font_name, chisel_font)
      chisel_font
    end
  end

  defp get_by(font_name) do
    if chisel_font = Agent.get(__MODULE__, &get_in(&1, [font_name])) do
      chisel_font
    end
  end

  defp save(font_name, %Chisel.Font{} = chisel_font) do
    Agent.update(__MODULE__, &put_in(&1, [font_name], chisel_font))
  end

  defp build_chisel_font(bdf_font_name) do
    {:ok, %Chisel.Font{} = chisel_font} = raw_font_file(bdf_font_name) |> Chisel.Font.load()

    chisel_font
  end

  defp download_raw_font!(font_name) do
    %Req.Response{status: 200, body: body} = Req.get!(raw_font_remote_url(font_name))
    :ok = File.write(raw_font_file(font_name), body)
  end

  defp raw_font_file(bdf_font_name) do
    Path.join([@fonts_dir, bdf_font_name])
  end

  defp raw_font_remote_url(bdf_font_name) do
    Path.join([@fonts_remote_base_url, bdf_font_name])
  end
end
