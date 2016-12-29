defmodule Exexif.Data.Thumbnail do
  @fields [
    :thumbnail_offset,
    :thumbnail_size
  ]

  def fields, do: @fields

  defstruct @fields

  def to_image(_, %Exexif.Data.Thumbnail{thumbnail_offset: offset, thumbnail_size: size}) when is_nil(offset) or is_nil(size), do: nil
  def to_image(file, %Exexif.Data.Thumbnail{thumbnail_offset: offset, thumbnail_size: size}) when is_binary(file) do
    [name, dot, ext] = String.split(file, ~r/(?=.{3,4}\z)/)
    File.open!(file, [:read], fn(from) ->
      File.open!("#{name}-thumb#{dot}#{ext}", [:write], fn(to) ->
        IO.binread(from, offset)
        IO.binwrite to, (IO.binread(from, size))
      end)
    end)
  end

  defimpl String.Chars, for: Exexif.Data.Thumbnail do
    def to_string(data), do: "Image Thumbnail of size #{data.thumbnail_size}"
  end
end
