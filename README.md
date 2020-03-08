# Exexif

_Read TIFF and EXIF information from a JPEG-format image._

### Retrieve data from a file:

```elixir
iex> {:ok, info} = Exexif.exif_from_jpeg_file(path)
```

Retrieve data from a binary containing the JPEG (you don't need the whole
thing—the exif is near the beginning of a JPEG, so 100k or so should
do fine).

```elixir
iex> {:ok, info} = Exexif.exif_from_jpeg_buffer(buffer)
```

### Access the high level TIFF data:

```elixir
iex> info.x_resolution
72
iex> info.model
"DSC-RX100M2"
```

### The exif data is in there, too.

```elixir
iex> info.exif.color_space
"sRGB"
```

```elixir
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
```

### GPS data is in there, too (if presented in EXIF, of course.)

```elixir
iex> {:ok, info} = Exexif.exif_from_jpeg_file("test/images/sunrise.jpg")
{:ok,
 %{exif: %{color_space: "Uncalibrated", exif_version: "2.10", ...},
   gps: %Exexif.Data.Gps{gps_altitude: 47, gps_altitude_ref: 0, ...},
   make: "ulefone", model: "Power", modify_date: "\"2016:12:28 14:04:48\"",
   orientation: "Horizontal (normal)", resolution_units: "Pixels/in",
   x_resolution: 72, y_resolution: 72}}

iex> info.gps.gps_latitude
[41, 23, 16.019]

iex> "#{info.gps}"
"41°23´16˝N,2°11´50˝E"
```

Todo
----

The exif tag list is missing some of the newer entries. Contributions welcome.


License and Copyright
---------------------

See LICENSE.md
