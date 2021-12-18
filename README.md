# NervesInkyPhatWeatherExample

![20211217_115119](https://user-images.githubusercontent.com/7563926/146623097-445833c7-a37a-44f1-a893-3a83a6337328.jpg)

[Inky pHAT](https://shop.pimoroni.com/products/inky-phat) is an electronic paper (ePaper / eInk / EPD) display for [Raspberry Pi](https://www.raspberrypi.org/).

Let's do something similar to [Pimoroni's Inky pHAT weather example](https://learn.pimoroni.com/article/getting-started-with-inky-phat#weather-example) in [Elixir](https://elixir-lang.org/).



## Targets

Nerves applications produce images for hardware targets based on the
`MIX_TARGET` environment variable. If `MIX_TARGET` is unset, `mix` builds an
image that runs on the host (e.g., your laptop). This is useful for executing
logic tests, running utilities, and debugging. Other targets are represented by
a short name like `rpi3` that maps to a Nerves system image for that platform.
All of this logic is in the generated `mix.exs` and may be customized. For more
information about targets see:

https://hexdocs.pm/nerves/targets.html#content

## Getting Started

To start your Nerves app:
  * `export MIX_TARGET=my_target` or prefix every command with
    `MIX_TARGET=my_target`. For example, `MIX_TARGET=rpi3`
  * Install dependencies with `mix deps.get`
  * Create firmware with `mix firmware`
  * Burn to an SD card with `mix firmware.burn`

## Dependencies

- [chisel](https://hex.pm/packages/chisel)
  - use bitmap fonts
- [inky](https://hex.pm/packages/inky)
  - drive the Inky eInk displays
  - this example uses [my fork](https://github.com/mnishiguchi/inky/tree/mnishiguchi/ssd1608) because the library does not support latest Inky PHAT device.
- [jason](https://hex.pm/packages/jason)
  - JSON parser
- [httpoison](https://hex.pm/packages/httpoison)
  - HTTP client

## Icons

- Icons are adopted from [https://github.com/pimoroni/inky](https://github.com/pimoroni/inky/tree/fc17026df35447c1147e9bfa38988e89e75c80e6/examples/phat/resources)
- The original icons were PNG, but I converted them into pixels so that I can use them easily in my code.
- I used [pixels](https://hex.pm/packages/pixels) package as a tool for converting PNG into pixels.
## Weather

- Weather info is fetched from https://wttr.in/?format=j1

## Fonts

- Fonts are fetched from https://github.com/olikraus/u8g2/tree/master/tools/font/bdf

## Learn more

  * Official docs: https://hexdocs.pm/nerves/getting-started.html
  * Official website: https://nerves-project.org/
  * Forum: https://elixirforum.com/c/nerves-forum
  * Discussion Slack elixir-lang #nerves ([Invite](https://elixir-slackin.herokuapp.com/))
  * Source: https://github.com/nerves-project/nerves
