defmodule Exexif do

  alias Exexif.Decode
  alias Exexif.Tag

  @max_exif_len          2*(65536+2)

  @image_start_marker   0xffd8
  @image_end_marker     0xffd9

  @app1_marker 0xffe1


  def exif_from_jpeg_file(name) when is_binary(name) do
    {:ok, buffer} = File.open(name, 
                              [:read], 
                              fn (file) -> 
                                IO.binread(file, @max_exif_len)
                              end)
    exif_from_jpeg_buffer(buffer)
  end


  def exif_from_jpeg_buffer(<< @image_start_marker :: 16, rest :: binary>>) do
    read_exif(rest)
  end

  def exif_from_jpeg_buffer(_), do: {:error, :not_a_jpeg_file}


  def read_exif(<< 
                  @app1_marker :: 16, 
                  _len         :: 16, 
                  "Exif"       :: binary,
                  0            :: 16,
                  exif         :: binary
                >>) do

    <<
      byte_order   :: 16,
      forty_two    :: binary-size(2),
      offset       :: binary-size(4),
      _rest        :: binary          >> = exif

    endian = case byte_order do
               0x4949 -> :little
               0x4d4d -> :big
             end

    read_unsigned = fn (value) -> :binary.decode_unsigned(value, endian) end

    42     = read_unsigned.(forty_two)  # sanity check
    offset = read_unsigned.(offset)

    { :ok, read_ifd({exif, offset, read_unsigned}) }
  end

  def read_exif(<< 0xff :: 8, _number :: 8, len :: 16, data :: binary>>) do
    # IO.puts "Skip segment #{number}"
    skip_segment(len-2, data)
    |> read_exif()
  end

  def read_exif(_) do
    { :error, :no_exif_data_in_jpeg }
  end

  def skip_segment(len, data) do
    << _segment :: size(len)-unit(8), rest :: binary >> = data
    rest
  end


  def read_ifd({exif, offset, ru} = context) do
    << _ :: binary-size(offset), tag_count :: binary-size(2), tags :: binary  >> = exif
    read_tags(ru.(tag_count), tags, context, :tiff, [])
  end


  def read_tags(0, _tags, _context, _type, result) do
    Enum.into(result, %{})
  end

  def read_tags(count, 
                << 
                  tag :: binary-size(2), 
                  format :: binary-size(2),
                  component_count :: binary-size(4),
                  value :: binary-size(4),
                  rest :: binary
                >>,
                {_exif, _offset, ru} = context,
                type,
                result) do
    tag    = ru.(tag)
    format = ru.(format)
    component_count = ru.(component_count)
    value = Tag.value(format, component_count, value, context)
    {name, description} = Decode.tag(type, tag, value)
    kv = case name do
      :exif -> { :exif, read_exif(value, context) }
      _     -> { name,  description }
    end
    read_tags(count-1, rest, context, type, [ kv | result ])
  end

  def read_tags(_, _, _, _, result) do # Handle malformed data
    Enum.into(result, %{})
  end

  def read_exif(exif_offset, {exif, _offset, ru} = context) do
    << _ :: binary-size(exif_offset), count :: binary-size(2), tags :: binary >> = exif
    count = ru.(count)
    read_tags(count, tags, context, :exif, [])
  end
end
