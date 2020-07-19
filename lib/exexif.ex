defmodule Exexif do
  @moduledoc """
  Read TIFF and EXIF information from a JPEG-format image.

      iex> {:ok, info} = Exexif.exif_from_jpeg_buffer(buffer)
      iex> info.x_resolution
      72
      iex> info.model
      "DSC-RX100M2"
      ...> Exexif.Data.Gps.inspect info
      "41°23´16˝N,2°11´50˝E"
  """

  alias Exexif.{Decode, Tag}
  alias Exexif.Data.{Gps, Thumbnail}

  @type t :: %{
          :brightness_value => float(),
          :color_space => binary(),
          :component_configuration => binary(),
          :compressed_bits_per_pixel => non_neg_integer(),
          :contrast => binary(),
          :custom_rendered => binary(),
          :datetime_digitized => binary(),
          :datetime_original => binary(),
          :digital_zoom_ratio => non_neg_integer(),
          :exif_image_height => non_neg_integer(),
          :exif_image_width => non_neg_integer(),
          :exif_version => binary(),
          :exposure_mode => binary(),
          :exposure_bias_value => non_neg_integer(),
          :exposure_program => binary(),
          :exposure_time => binary(),
          :f_number => non_neg_integer(),
          :file_source => binary(),
          :flash => binary(),
          :flash_pix_version => binary(),
          :focal_length_in_35mm_film => non_neg_integer(),
          :focal_length => float(),
          :iso_speed_ratings => non_neg_integer(),
          :lens_info => [float()],
          :light_source => non_neg_integer(),
          :max_aperture_value => float(),
          :metering_mode => binary(),
          :recommended_exposure => non_neg_integer(),
          :saturation => binary(),
          :scene_capture_type => binary(),
          :scene_type => binary(),
          :sensitivity_type => binary(),
          :sharpness => binary(),
          :white_balance => binary()
        }

  # <<_::32>>
  @type value :: binary()
  @type context :: {value(), non_neg_integer(), (any() -> non_neg_integer())}

  @max_exif_len 2 * (65_536 + 2)

  @image_start_marker 0xFFD8
  # @image_end_marker     0xffd9 # NOT USED

  @app1_marker 0xFFE1

  @spec exif_from_jpeg_file(binary()) ::
          {:error, :no_exif_data_in_jpeg | :not_a_jpeg_file | :file.posix()}
          | {:ok, %{exif: t()}}
  @doc "Extracts EXIF from jpeg file"
  def exif_from_jpeg_file(name) when is_binary(name) do
    with {:ok, buffer} <- File.open(name, [:read], &IO.binread(&1, @max_exif_len)),
         do: exif_from_jpeg_buffer(buffer)
  end

  @doc "Extracts EXIF from jpeg file, raises on any error"
  @spec exif_from_jpeg_file!(binary()) :: %{exif: t()} | no_return()
  def exif_from_jpeg_file!(name) when is_binary(name) do
    case exif_from_jpeg_file(name) do
      {:ok, result} -> result
      {:error, error} -> raise(Exexif.ReadError, type: error, file: name)
    end
  end

  @spec exif_from_jpeg_buffer(binary()) ::
          {:error, :no_exif_data_in_jpeg | :not_a_jpeg_file} | {:ok, %{exif: t()}}
  @doc "Extracts EXIF from binary buffer"
  def exif_from_jpeg_buffer(<<@image_start_marker::16, rest::binary>>),
    do: read_exif(rest)

  def exif_from_jpeg_buffer(_), do: {:error, :not_a_jpeg_file}

  @spec exif_from_jpeg_buffer!(binary()) :: %{exif: t()} | no_return()
  @doc "Extracts EXIF from binary buffer, raises on any error"
  def exif_from_jpeg_buffer!(buffer) do
    case exif_from_jpeg_buffer(buffer) do
      {:ok, result} -> result
      {:error, error} -> raise Exexif.ReadError, type: error, file: nil
    end
  end

  @spec read_exif(binary()) :: {:error, :no_exif_data_in_jpeg} | {:ok, %{exif: t()}}
  def read_exif(<<
        @app1_marker::16,
        _len::16,
        "Exif"::binary,
        0::16,
        exif::binary
      >>) do
    <<
      byte_order::16,
      forty_two::binary-size(2),
      offset::binary-size(4),
      _rest::binary
    >> = exif

    endian =
      case byte_order do
        0x4949 -> :little
        0x4D4D -> :big
      end

    read_unsigned = &:binary.decode_unsigned(&1, endian)

    # sanity check
    42 = read_unsigned.(forty_two)
    offset = read_unsigned.(offset)

    {:ok, reshape(read_ifd({exif, offset, read_unsigned}))}
  end

  def read_exif(<<0xFF::8, _number::8, len::16, data::binary>>) do
    (len - 2)
    |> skip_segment(data)
    |> read_exif()
  end

  def read_exif(_), do: {:error, :no_exif_data_in_jpeg}

  @spec skip_segment(len :: non_neg_integer(), data :: binary()) :: binary()
  defp skip_segment(len, data) do
    <<_segment::size(len)-unit(8), rest::binary>> = data
    rest
  end

  @spec read_ifd(context :: context()) :: map()
  defp read_ifd({exif, offset, ru} = context) do
    case exif do
      <<_::binary-size(offset), tag_count::binary-size(2), tags::binary>> ->
        read_tags(ru.(tag_count), tags, context, :tiff, [])

      _ ->
        %{}
    end
  end

  @spec read_tags(non_neg_integer(), binary(), context(), any(), any()) :: map()
  defp read_tags(0, _tags, _context, _type, result), do: Map.new(result)

  defp read_tags(
         count,
         <<
           tag::binary-size(2),
           format::binary-size(2),
           component_count::binary-size(4),
           value::binary-size(4),
           rest::binary
         >>,
         {_exif, _offset, ru} = context,
         type,
         result
       ) do
    tag = ru.(tag)
    format = ru.(format)
    component_count = ru.(component_count)
    value = Tag.value(format, component_count, value, context)
    {name, description} = Decode.tag(type, tag, value)

    kv =
      case name do
        :exif -> {:exif, read_exif(value, context)}
        :gps -> {:gps, read_gps(value, context)}
        _ -> {name, description}
      end

    read_tags(count - 1, rest, context, type, [kv | result])
  end

  # Handle malformed data
  defp read_tags(_, _, _, _, result), do: Map.new(result)

  def read_exif(exif_offset, {exif, _offset, ru} = context) do
    <<_::binary-size(exif_offset), count::binary-size(2), tags::binary>> = exif
    count = ru.(count)
    read_tags(count, tags, context, :exif, [])
  end

  @spec read_gps(non_neg_integer(), context()) :: %Gps{}
  defp read_gps(gps_offset, {gps, _offset, ru} = context) do
    case gps do
      <<_::binary-size(gps_offset), count::binary-size(2), tags::binary>> ->
        struct(Gps, read_tags(ru.(count), tags, context, :gps, []))

      _ ->
        %Gps{}
    end
  end

  @spec reshape(%{exif: t()}) :: %{exif: t()}
  defp reshape(result), do: extract_thumbnail(result)

  @spec extract_thumbnail(%{exif: t()}) :: %{exif: t()}
  defp extract_thumbnail(result) do
    exif_keys = Map.keys(result.exif)

    result =
      if Enum.all?(Thumbnail.fields(), fn e -> Enum.any?(exif_keys, &(&1 == e)) end) do
        Map.put(
          result,
          :thumbnail,
          struct(
            Thumbnail,
            Thumbnail.fields()
            |> Enum.map(fn e -> {e, result.exif[e]} end)
            |> Enum.into(%{})
          )
        )
      else
        result
      end

    %{result | exif: Map.drop(result.exif, Thumbnail.fields())}
  end
end
