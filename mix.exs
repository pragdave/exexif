defmodule Exexif.Mixfile do
  use Mix.Project

  def project do
    [
      app:         :exexif,
      version:     "0.0.5",
      elixir:      ">= 1.1.0",
      deps:        [ {:ex_doc, ">= 0.0.0", only: :dev} ],
      description: description(),
      package:     package(),
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

  @me "Dave Thomas <dave@pragprog.org>"
  defp package do
    [
      files:        [ "lib", "mix.exs", "README.md", "LICENSE.md" ],
      maintainers:  [ @me ],
      contributors: [ @me, "Aleksei Matiushkin <am@mudasobwa.ru>"],
      licenses:     [ "MIT. See LICENSE.md" ],
      links:        %{
                       "GitHub" => "https://github.com/pragdave/exexif",
                    }
    ]
  end

end
