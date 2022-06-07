defmodule HelloNervesInkyPhatWeather.Font do
  @moduledoc false

  @fonts_dir "/data/fonts"

  def load!(font_name) do
    File.mkdir_p(@fonts_dir)

    src = font_source_url(font_name)
    dest = font_destination_file(font_name)

    if not File.exists?(dest) do
      :ok = download!(src, dest)
    end

    {:ok, chisel_font} = Chisel.Font.load(dest)
    chisel_font
  end

  defp download!(src, dest) do
    {:ok, {{_, 200, _}, _headers, body}} = :httpc.request(src)
    :ok = File.write(dest, List.to_string(body))
  end

  defp font_destination_file(font_name) do
    Path.join([@fonts_dir, "#{font_name}.bdf"])
  end

  defp font_source_url(font_name) do
    "https://raw.githubusercontent.com/olikraus/u8g2/master/tools/font/bdf/#{font_name}.bdf"
  end
end
