defmodule GpsTest do
  use ExUnit.Case
  import Exexif

  @data File.read!("test/images/sunrise.jpg")

  test "tiff fields are reasonable" do
    {:ok, metadata} = exif_from_jpeg_buffer(@data)

    assert %{
             :make => "ulefone",
             :model => "Power",
             :modify_date => "\"2016:12:28 14:04:48\"",
             :orientation => "Horizontal (normal)",
             :resolution_units => "Pixels/in",
             :x_resolution => 72,
             :y_resolution => 72
           } = metadata
  end

  test "gps fields are reasonable" do
    {:ok, metadata} = exif_from_jpeg_buffer(@data)

    assert %Exexif.Data.Gps{
             gps_altitude: 47,
             gps_altitude_ref: 0,
             gps_date_stamp: "2016:12:27",
             gps_img_direction: 125.25,
             gps_img_direction_ref: "M",
             gps_latitude: [41, 23, 16.019],
             gps_latitude_ref: "N",
             gps_longitude: [2, 11, 49.584],
             gps_longitude_ref: "E",
             gps_processing_method: 0,
             gps_time_stamp: [6, 42, 48]
           } = metadata.gps
  end

  test "gps is printed in human readable manner" do
    {:ok, metadata} = exif_from_jpeg_buffer(@data)

    assert "#{metadata.gps}" == "41°23´16˝N,2°11´50˝E"
  end
end
