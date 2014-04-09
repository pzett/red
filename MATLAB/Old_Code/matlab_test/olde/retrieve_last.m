names=list_sensor_log_files_on_sdcard

filename = char(names.filenames(end))

copy_file_from_sdcard_to_working_directory(filename);

log_data=get_log_data_from_FrameWork(filename);

sound=extract_sound_from_log_data(log_data)



