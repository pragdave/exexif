defmodule Exexif.Decode do

  @module_doc """
    Decode tags and (in some cases) their parameters
  """

  def tag(:tiff, 0x010d, value), do: { :document_name, value }
  def tag(:tiff, 0x010e, value), do: { :image_description, value }
  def tag(:tiff, 0x010f, value), do: { :make, value }
  def tag(:tiff, 0x0110, value), do: { :model, value }
  def tag(:tiff, 0x0112, value), do: { :orientation, orientation(value) }
  def tag(:tiff, 0x011a, value), do: { :x_resolution, value }
  def tag(:tiff, 0x011b, value), do: { :y_resolution, value }
  def tag(:tiff, 0x0128, value), do: { :resolution_units, resolution(value) }
  def tag(:tiff, 0x0131, value), do: { :software, value }
  def tag(:tiff, 0x0132, value), do: { :modify_date, inspect(value) }
  def tag(:tiff, 0x8769, value), do: { :exif, value }
      

  def tag(:exif, 0x829a, value), do: {:exposure_time, value }
  def tag(:exif, 0x829d, value), do: {:f_number, value }
  def tag(:exif, 0x8822, value), do: {:exposure_program, exposure_program(value) }
  def tag(:exif, 0x8824, value), do: {:spectral_sensitivity, value }
  def tag(:exif, 0x8827, value), do: {:iso_speed_ratings, value }
  def tag(:exif, 0x8828, value), do: {:oecf, value }
  def tag(:exif, 0x8830, value), do: {:sensitivity_type, sensitivity_type(value) }
  def tag(:exif, 0x8831, value), do: {:standard_output_sensitivity, value }
  def tag(:exif, 0x8832, value), do: {:recommended_exposure, value }
  def tag(:exif, 0x9000, value), do: {:exif_version, version(value) }
  def tag(:exif, 0x9003, value), do: {:datetime_original, value }
  def tag(:exif, 0x9004, value), do: {:datetime_digitized, value }
  def tag(:exif, 0x9101, value), do: {:component_configuration, component_configuration(value) }
  def tag(:exif, 0x9102, value), do: {:compressed_bits_per_pixel, value }
  def tag(:exif, 0x9201, value), do: {:shutter_speed_value, value }
  def tag(:exif, 0x9202, value), do: {:aperture_value, value }
  def tag(:exif, 0x9203, value), do: {:brightness_value, value }
  def tag(:exif, 0x9204, value), do: {:exposure_bias_value, value }
  def tag(:exif, 0x9205, value), do: {:max_aperture_value, value }
  def tag(:exif, 0x9206, value), do: {:subject_distance, value }
  def tag(:exif, 0x9207, value), do: {:metering_mode, metering_mode(value) }
  def tag(:exif, 0x9208, value), do: {:light_source, value }
  def tag(:exif, 0x9209, value), do: {:flash, flash(value) }
  def tag(:exif, 0x920a, value), do: {:focal_length, value }
  def tag(:exif, 0x9214, value), do: {:subject_area, value }
  def tag(:exif, 0x927c, value), do: {:maker_note, value }
  def tag(:exif, 0x9286, value), do: {:user_comment, value }
  def tag(:exif, 0x9290, value), do: {:subsec_time, value }
  def tag(:exif, 0x9291, value), do: {:subsec_time_orginal, value }
  def tag(:exif, 0x9292, value), do: {:subsec_time_digitized, value }
  def tag(:exif, 0xa000, value), do: {:flash_pix_version, version(value) }
  def tag(:exif, 0xa001, value), do: {:color_space, color_space(value) }
  def tag(:exif, 0xa002, value), do: {:exif_image_width, value }
  def tag(:exif, 0xa003, value), do: {:exif_image_height, value }
  def tag(:exif, 0xa004, value), do: {:related_sound_file, value }
  def tag(:exif, 0xa20b, value), do: {:flash_energy, value }
  def tag(:exif, 0xa20c, value), do: {:spatial_frequency_response, value }
  def tag(:exif, 0xa20e, value), do: {:focal_plane_x_resolution, value }	
  def tag(:exif, 0xa20f, value), do: {:focal_plane_y_resolution, value }
  def tag(:exif, 0xa210, value), do: {:focal_plane_resolution_unit, focal_plane_resolution_unit(value) }
  def tag(:exif, 0xa214, value), do: {:subject_location, value }
  def tag(:exif, 0xa215, value), do: {:exposure_index, value }
  def tag(:exif, 0xa217, value), do: {:sensing_method, sensing_method(value) }
  def tag(:exif, 0xa300, value), do: {:file_source, file_source(value) }
  def tag(:exif, 0xa301, value), do: {:scene_type, scene_type(value) }
  def tag(:exif, 0xa302, value), do: {:cfa_pattern, value }
  def tag(:exif, 0xa401, value), do: {:custom_rendered, custom_rendered(value) }
  def tag(:exif, 0xa402, value), do: {:exposure_mode, exposure_mode(value) }
  def tag(:exif, 0xa403, value), do: {:white_balance, white_balance(value) }
  def tag(:exif, 0xa404, value), do: {:digital_zoom_ratio, value }
  def tag(:exif, 0xa405, value), do: {:focal_length_in_35mm_film, value }
  def tag(:exif, 0xa406, value), do: {:scene_capture_type, scene_capture_type(value) }
  def tag(:exif, 0xa407, value), do: {:gain_control, gain_control(value) }
  def tag(:exif, 0xa408, value), do: {:contrast, contrast(value) }
  def tag(:exif, 0xa409, value), do: {:saturation, saturation(value) }
  def tag(:exif, 0xa40a, value), do: {:sharpness, sharpness(value) }
  def tag(:exif, 0xa40b, value), do: {:device_setting_description, value }
  def tag(:exif, 0xa40c, value), do: {:subject_distance_range, subject_distance_range(value) }
  def tag(:exif, 0xa420, value), do: {:image_unique_id, value }
  def tag(:exif, 0xa432, value), do: {:lens_info, value }
  def tag(:exif, 0xa433, value), do: {:lens_make, value }
  def tag(:exif, 0xa434, value), do: {:lens_model, value }
  def tag(:exif, 0xa435, value), do: {:lens_serial_number, value }



  def tag(type, tag, value) do
    {~s[#{type} tag(0x#{:io_lib.format("~.16B", [tag])})], inspect value }
  end

  # Value decodes

  defp orientation(1), do: "Horizontal (normal)"
  defp orientation(2), do: "Mirror horizontal"
  defp orientation(3), do: "Rotate 180"
  defp orientation(4), do: "Mirror vertical"
  defp orientation(5), do: "Mirror horizontal and rotate 270 CW"
  defp orientation(6), do: "Rotate 90 CW"
  defp orientation(7), do: "Mirror horizontal and rotate 90 CW"
  defp orientation(8), do: "Rotate 270 CW"

  defp resolution(1), do: "None"
  defp resolution(2), do: "Pixels/in"
  defp resolution(3), do: "Pixels/cm"

  defp exposure_program(1), do: "Manual"
  defp exposure_program(2), do: "Program AE"
  defp exposure_program(3), do: "Aperture-priority AE"
  defp exposure_program(4), do: "Shutter speed priority AE"
  defp exposure_program(5), do: "Creative (Slow speed)"
  defp exposure_program(6), do: "Action (High speed)"
  defp exposure_program(7), do: "Portrait"
  defp exposure_program(8), do: "Landscape"
  defp exposure_program(9), do: "Bulb"

  defp sensitivity_type(0), do: "Unknown"
  defp sensitivity_type(1), do: "Standard Output Sensitivity"
  defp sensitivity_type(2), do: "Recommended Exposure Index"
  defp sensitivity_type(3), do: "ISO Speed"
  defp sensitivity_type(4), do: " Standard Output Sensitivity and Recommended Exposure Index" 
  defp sensitivity_type(5), do: "Standard Output Sensitivity and ISO Speed"
  defp sensitivity_type(6), do: "Recommended Exposure Index and ISO Speed"
  defp sensitivity_type(7), do: "Standard Output Sensitivity, Recommended Exposure Index and ISO Speed"

  @comp_conf { "-", "Y", "Cb", "Cr", "R", "G", "B" }

  defp component_configuration(list) do
    for cc <- list do
      elem(@comp_conf, cc)
    end
    |> Enum.join(",")
  end

  defp metering_mode(0),   do: "Unknown"
  defp metering_mode(1),   do: "Average"
  defp metering_mode(2),   do: "Center-weighted average"
  defp metering_mode(3),   do: "Spot"
  defp metering_mode(4),   do: "Multi-spot"
  defp metering_mode(5),   do: "Multi-segment"
  defp metering_mode(6),   do: "Partial"
  defp metering_mode(255), do: "Other"


  defp color_space(0x1),    do: "sRGB"
  defp color_space(0x2),    do: "Adobe RGB"
  defp color_space(0xfffd), do: "Wide Gamut RGB"
  defp color_space(0xfffe), do: "ICC Profile"
  defp color_space(0xffff), do: "Uncalibrated"


  defp focal_plane_resolution_unit(1), do: "None"
  defp focal_plane_resolution_unit(2), do: "inches"
  defp focal_plane_resolution_unit(3), do: "cm"
  defp focal_plane_resolution_unit(4), do: "mm"
  defp focal_plane_resolution_unit(5), do: "um"


  defp sensing_method(1), do: "Not defined"
  defp sensing_method(2), do: "One-chip color area"
  defp sensing_method(3), do: "Two-chip color area"
  defp sensing_method(4), do: "Three-chip color area"
  defp sensing_method(5), do: "Color sequential area"
  defp sensing_method(7), do: "Trilinear"
  defp sensing_method(8), do: "Color sequential linear"

  defp file_source(1), do: "Film Scanner"
  defp file_source(2), do: "Reflection Print Scanner"
  defp file_source(3), do: "Digital Camera"
  defp file_source(0x03000000), do: "Sigma Digital Camera"

  defp custom_rendered(0), do: "Normal"
  defp custom_rendered(1), do: "Custom"

  defp scene_type(1), do: "Directly photographed"

  defp exposure_mode(0), do: "Auto"
  defp exposure_mode(1), do: "Manual"
  defp exposure_mode(2), do: "Auto bracket"

  defp white_balance(0), do: "Auto"
  defp white_balance(1), do: "Manual"

  defp scene_capture_type(0), do: "Standard"
  defp scene_capture_type(1), do: "Landscape"
  defp scene_capture_type(2), do: "Portrait"
  defp scene_capture_type(3), do: "Night"

  defp gain_control(0), do: "None"
  defp gain_control(1), do: "Low gain up"
  defp gain_control(2), do: "High gain up"
  defp gain_control(3), do: "Low gain down"
  defp gain_control(4), do: "High gain down"

  defp contrast(0), do: "Normal"
  defp contrast(1), do: "Low"
  defp contrast(2), do: "High"

  defp saturation(0), do: "Normal"
  defp saturation(1), do: "Low"
  defp saturation(2), do: "High"

  defp sharpness(0), do: "Normal"
  defp sharpness(1), do: "Soft"
  defp sharpness(2), do: "Hard"

  defp subject_distance_range(0), do: "Unknown"
  defp subject_distance_range(1), do: "Macro"
  defp subject_distance_range(2), do: "Close"
  defp subject_distance_range(3), do: "Distant"

  defp flash(0x0),  do: "No Flash"
  defp flash(0x1),  do: "Fired"
  defp flash(0x5),  do: "Fired, Return not detected"
  defp flash(0x7),  do: "Fired, Return detected"
  defp flash(0x8),  do: "On, Did not fire"
  defp flash(0x9),  do: "On, Fired"
  defp flash(0xd),  do: "On, Return not detected"
  defp flash(0xf),  do: "On, Return detected"
  defp flash(0x10), do: "Off, Did not fire"
  defp flash(0x14), do: "Off, Did not fire, Return not detected"
  defp flash(0x18), do: "Auto, Did not fire"
  defp flash(0x19), do: "Auto, Fired"
  defp flash(0x1d), do: "Auto, Fired, Return not detected"
  defp flash(0x1f), do: "Auto, Fired, Return detected"
  defp flash(0x20), do: "No flash function"
  defp flash(0x30), do: "Off, No flash function"
  defp flash(0x41), do: "Fired, Red-eye reduction"
  defp flash(0x45), do: "Fired, Red-eye reduction, Return not detected"
  defp flash(0x47), do: "Fired, Red-eye reduction, Return detected"
  defp flash(0x49), do: "On, Red-eye reduction"
  defp flash(0x4d), do: "On, Red-eye reduction, Return not detected"
  defp flash(0x4f), do: "On, Red-eye reduction, Return detected"
  defp flash(0x50), do: "Off, Red-eye reduction"
  defp flash(0x58), do: "Auto, Did not fire, Red-eye reduction"
  defp flash(0x59), do: "Auto, Fired, Red-eye reduction"
  defp flash(0x5d), do: "Auto, Fired, Red-eye reduction, Return not detected"
  defp flash(0x5f), do: "Auto, Fired, Red-eye reduction, Return detected"

  defp version([ ?0, major, minor1, minor2 ]) do
    << major, ?., minor1, minor2 >>
  end
  defp version([ major1, major2, minor1, minor2 ]) do
    << major1, major2, ?., minor1, minor2 >>
  end

end
