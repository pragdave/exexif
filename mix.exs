defmodule Exexif.Mixfile do
  use Mix.Project

  def project do
    [app: :exexif,
     version: "0.0.3",
     elixir: "~> 1.1-dev",
     deps: [],
     description: description(),
     package:     package(),
    ]
  end

  def application do
    [applications: []]
  end

  defp description do
    """
    Read TIFF and EXIF information from a JPEG-format image.


    1. Retrieve data from a file:

            iex> {:ok, info} = Exexif.exif_from_jpeg_file(path)

       Retrieve data from a binary containing the JPEG (you don't need the whole
       thing—the exif is near the beginning of a JPEG, so 100k or so should
       do fine).

            iex> {:ok, info} = Exexif.exif_from_jpeg_buffer(buffer)

    2. Access the high level TIFF data:

            iex> info.x_resolution
            72
            iex> info.model
            "DSC-RX100M2"

    3. The exif data is in there, too.

            iex> info.exif.color_space
            "sRGB"

            iex> info.exif |> Dict.keys
            [:brightness_value, :color_space, :component_configuration,
             :compressed_bits_per_pixel, :contrast, :custom_rendered, :datetime_original,
             :datetime_digitized, :digital_zoom_ratio, :exif_image_height,
             :exif_image_width, :exif_version, :exposure_bias_value, :exposure_mode,
             :exposure_program, :exposure_time, :f_number, :file_source, :flash,
             :flash_pix_persion, :focal_length, :focal_length_in_35mm_film,
             :iso_speed_ratings, :lens_info, :light_source, :max_aperture_value,
             :metering_mode, :recommended_exposure, :saturation, :scene_capture_type,
             :scene_type, :sensitivity_type, :sharpness, :white_balance]

    4. GPS data is in there, too (if presented in EXIF, of course.)

            iex> {:ok, info} = Exexif.exif_from_jpeg_file("test/images/sunrise.jpg")
            ...> info.gps.gps_latitude
            [41, 23, 16.019]

            iex> {:ok, info} = Exexif.exif_from_jpeg_file("test/images/sunrise.jpg")
            ...> Exexif.Data.Gps.inspect info
            "41°23´16˝N,2°11´50˝E"
    """
  end

  defp package do
    [
      files:        [ "lib", "mix.exs", "README.md", "LICENSE.md" ],
      contributors: [ "Dave Thomas <dave@pragprog.org>", "Aleksei Matiushkin <am@mudasobwa.ru>"],
      licenses:     [ "MIT. See LICENSE.md" ],
      links:        %{
                       "GitHub" => "https://github.com/pragdave/exexif",
                    }
    ]
  end

end
