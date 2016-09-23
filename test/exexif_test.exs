defmodule ExexifTest do
  use ExUnit.Case
  import Exexif

  @data    File.read!("test/images/pp_editors.jpg")

  test "looks for jpeg marker" do
    assert { :error, :not_a_jpeg_file } = exif_from_jpeg_buffer("wombat")
  end

  test "correctly reports no exif" do
    no_exif = "test/images/pp_editors_no_exif.jpg"
    assert {:error, :no_exif_data_in_jpeg} = exif_from_jpeg_file(no_exif)
  end

  test "handles exif" do
    assert {:ok, _metadata} = exif_from_jpeg_buffer(@data)
  end

  test "tiff fields are reasonable" do
    {:ok, metadata} = exif_from_jpeg_buffer(@data)

    assert %{
      :image_description => "                               ",
      :make              => "SONY", 
      :model             => "DSC-RX100M2",
      :modify_date       => "\"2014:05:14 11:57:07\"",
      :orientation       => "Horizontal (normal)",
      :resolution_units  => "Pixels/in", 
      :software          => "DSC-RX100M2 v1.00",
      :x_resolution      => 72, 
      :y_resolution      => 72,
    } = metadata
  end

  test "exif fields are reasonable" do
    {:ok, metadata} = exif_from_jpeg_buffer(@data)

    exif = metadata.exif

    assert %{
      :brightness_value          => 7.084, 
      :color_space               => "sRGB",
      :component_configuration   => "Y,Cb,Cr,-", 
      :compressed_bits_per_pixel => 2,
      :contrast                  => "Normal", 
      :custom_rendered           => "Normal",
      :datetime_digitized        => "2014:05:14 11:57:07",
      :datetime_original         => "2014:05:14 11:57:07", 
      :digital_zoom_ratio        => 1,
      :exif_image_height         => 335, 
      :exif_image_width          => 800,
      :exif_version              => "2.30", 
      :exposure_mode             => "Auto",
      :exposure_bias_value       => 0, 
      :exposure_program          => "Program AE",
      :exposure_time             => "1/200", 
      :f_number                  => 4, 
      :file_source               => "Digital Camera",
      :flash                     => "Off, Did not fire", 
      :flash_pix_version         => "1.00",
      :focal_length_in_35mm_film => 28, 
      :focal_length              => 10.4,
      :iso_speed_ratings         => 160, 
      :lens_info                 => [10.4, 37.1, 1.8, 4.9],
      :light_source              => 0, 
      :max_aperture_value        => 1.695,
      :metering_mode             => "Multi-segment", 
      :recommended_exposure      => 160,
      :saturation                => "Normal", 
      :scene_capture_type        => "Standard",
      :scene_type                => "Directly photographed",
      :sensitivity_type          => "Recommended Exposure Index",
      :sharpness                 => "Normal", 
      :white_balance             => "Auto"
    } = exif
  end

  test "malformed images" do
    assert {:ok, data} = exif_from_jpeg_file("test/images/malformed.jpg")
    assert %{make: "SAMSUNG"} = data
  end

  test "bad values" do
    # Apple Aperture inserts invalid values
    assert {:ok, data} = exif_from_app1_file("test/images/apple-aperture-1.5.app1")
    assert %{make: "NIKON CORPORATION"} = data
  end

  test "infinity" do
    # GoPro uses ratio numerator 0 to relay infinity
    assert {:ok, data} = exif_from_app1_file("test/images/gopro_hd2.app1")
    assert %{exif: %{subject_distance: :infinity}} = data
  end

  test "negative exposure bias" do
    assert {:ok, data} = exif_from_app1_file("test/images/negative-exposure-bias-value.app1")
    assert %{exif: %{exposure_bias_value: -0.333}} = data
  end

  defp exif_from_app1_file(path) do
    read_exif(File.read!(path))
  end
end
