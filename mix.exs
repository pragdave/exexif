defmodule Exexif.Mixfile do
  use Mix.Project

  def project do
    [
      app: :nextexif,
      version: "0.1.0",
      elixir: ">= 1.6.0",
      deps: deps(),
      aliases: aliases(),
      description: description(),
      package: package()
    ]
  end

  def application do
    [
      applications: []
    ]
  end

  defp description do
    """
    Read TIFF and EXIF information from a JPEG-format image.

            iex> {:ok, info} = Exexif.exif_from_jpeg_buffer(buffer)
            iex> info.x_resolution
            72
            iex> info.model
            "DSC-RX100M2"
            ...> Exexif.Data.Gps.inspect info
            "41°23´16˝N,2°11´50˝E"
    """
  end

  @me "Aleksei Matiushkin <am@mudasobwa.ru>"
  defp package do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE.md"],
      maintainers: [@me],
      contributors: ["Dave Thomas <dave@pragprog.org>", @me],
      licenses: ["MIT. See LICENSE.md"],
      links: %{
        "GitHub" => "https://github.com/am-kantox/exexif"
      }
    ]
  end

  defp aliases do
    [
      quality: ["format", "credo --strict", "dialyzer"],
      "quality.ci": [
        "format --check-formatted",
        "credo --strict",
        "dialyzer"
      ]
    ]
  end

  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: [:dev], runtime: false},
      {:credo, "~> 1.0", only: [:dev, :ci], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev, :test, :ci], runtime: false}
    ]
  end
end
