defmodule Exexif.Data.Gps do
  @fields [
    :gps_version_id,
    :gps_latitude_ref,
    :gps_latitude,
    :gps_longitude_ref,
    :gps_longitude,
    :gps_altitude_ref,
    :gps_altitude,
    :gps_time_stamp,
    :gps_satellites,
    :gps_status,
    :gps_measure_mode,
    :gps_dop,
    :gps_speed_ref,
    :gps_speed,
    :gps_track_ref,
    :gps_track,
    :gps_img_direction_ref,
    :gps_img_direction,
    :gps_map_datum,
    :gps_dest_latitude_ref,
    :gps_dest_latitude,
    :gps_dest_longitude_ref,
    :gps_dest_longitude,
    :gps_dest_bearing_ref,
    :gps_dest_bearing,
    :gps_dest_distance_ref,
    :gps_dest_distance,
    :gps_processing_method,
    :gps_area_information,
    :gps_date_stamp,
    :gps_differential,
    :gps_h_positioning_errorl
  ]

  def fields, do: @fields

  defstruct @fields

  def inspect(%Exexif.Data.Gps{gps_latitude: nil} = _data), do: ""
  def inspect(%Exexif.Data.Gps{gps_longitude: nil} = _data), do: ""

  def inspect(%Exexif.Data.Gps{} = data) do
    # gps_latitude: [41, 23, 16.019], gps_latitude_ref: "N",
    # gps_longitude: [2, 11, 49.584], gps_longitude_ref: "E"
    # 41 deg 23' 16.02" N, 2 deg 11' 49.58" E
    [lat_d, lat_m, lat_s] = data.gps_latitude
    [lon_d, lon_m, lon_s] = data.gps_longitude
    [
      ~s|#{lat_d}°#{lat_m}´#{round(lat_s)}˝#{data.gps_latitude_ref || "N"}|,
      ~s|#{lon_d}°#{lon_m}´#{round(lon_s)}˝#{data.gps_longitude_ref || "N"}|
    ] |> Enum.join(",")
  end

  defimpl String.Chars, for: Exexif.Data.Gps do
    def to_string(data), do: Exexif.Data.Gps.inspect(data)
  end
end
