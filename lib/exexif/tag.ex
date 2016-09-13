defmodule Exexif.Tag do

  @moduledoc """
  Parse the different tag type values (strings, unsigned shorts, etc...)
  """

  @max_signed_32_bit_int 2147483647

  def value(1, count, value, context) do  # unsigned byte, size = 1
    decode_numeric(value, count, 2, context)
  end
    
  def value(2, count, value, context) do  # ascii string, size = 1
    {exif, offset, ru} = context
    length = count - 1  # ignore null-byte at end
    if count > 4 do
      offset = ru.(value)# + offset
      # IO.puts "offset #{offset}, length #{length}"
      << _ :: binary-size(offset), string :: binary-size(length), _ ::binary >> = exif
      string
    else
      << string :: binary-size(length), _ :: binary >> = value
      string
    end
  end


  def value(3, count, value, context) do  # unsigned short, size = 2
    decode_numeric(value, count, 2, context)
  end

  def value(4, count, value, context) do  # unsigned long, size = 4
    decode_numeric(value, count, 4, context)
  end

  def value(5, count, value, context) do  # unsigned rational, size = 8
    decode_ratio(value, count, 8, context)
  end

  # 
  # def value(6, count, value, rest, ru) do  # signed byte, size = 1
  #   # size 1                            
  # end
  # 
  def value(7, count, value, context) do  # undefined, size = 1
    decode_numeric(value, count, 1, context)
  end
  # 
  # def value(8, count, value, rest, ru) do  # signed short, size = 2
  #   # size 1                            
  # end
  # 
  # def value(9, count, value, rest, ru) do  # signed long, size = 4
  #   # size 1                            
  # end
  # 
  def value(10, count, value, context) do  # signed rational, size = 8
    decode_ratio(value, count, 8, context, :signed)
  end
  # 
  # def value(11, count, value, rest, ru) do  # single float, size = 4
  #   # size 1                            
  # end
  # 
  # def value(12, count, value, rest, ru) do  # double float, size = 4
  #   # size 1                            
  # end

  def value(_, _, _, _) do # Handle malformed tags
    nil
  end

  def decode_numeric(value, count, size,  {exif, _offset, ru}) do
    length = count * size
    values = if length > 4 do
      case exif do
        << _ :: binary-size(value), data :: binary-size(length), _ :: binary >> -> data
        _ -> nil # probably a maker_note or user_comment
      end
    else
      << data :: binary-size(length), _ :: binary >> = value
      data
    end
    if values do
      if count == 1 do
        ru.(values)
      else
        read_unsigned_many(values, size, ru)
      end
    end
  end


  def decode_ratio(value_offset, count, 8, {exif, _offset, ru}, signed \\ :unsigned) do
    offset = ru.(value_offset)
    result = decode_ratios(exif, count, offset, ru, signed)
    if count == 1 do
       hd(result)
    else
       result
    end
  end

  def decode_ratios(_data, 0, _offset, _ru, _signed) do
    []
  end

  def decode_ratios(data, count, offset, ru, signed) do
    << _           :: binary-size(offset),
       numerator   :: binary-size(4),
       denominator :: binary-size(4),
       rest        :: binary 
    >> = data
    d = maybe_signed_int(ru.(denominator), signed)
    n = maybe_signed_int(ru.(numerator),   signed)

    result = case {d,n}  do
      {1,n} -> n
      {d,1} -> "1/#{d}"
      {0,_} -> :infinity
      {d,n} -> round((n * 1000)/d)/1000
    end
    [ result | decode_ratios(rest, count-1, 0, ru, signed) ]
  end

  def read_unsigned_many(<<>>, _size, _ru) do
    []
  end

  def read_unsigned_many(data, size, ru) do
    << number :: binary-size(size), rest :: binary >> = data
    [ru.(number) | read_unsigned_many(rest, size, ru)]
  end

  def maybe_signed_int(x, :signed) when x > @max_signed_32_bit_int do
    x - @max_signed_32_bit_int - 1
  end
  def maybe_signed_int(x, _), do: x  # +ve or unsigned

end
