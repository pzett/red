function [ r] = retrieve_data( id  )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
%Pull out info from sensor
names = list_log([],id);
filename = char(names.filenames(end)); % Char converts cell to string
copy_file_from_sdcard(filename,id);%copy file to folder
log_data=get_log_data_from_FrameWork(filename) %grab log data
r=extract_sound_from_log_data(log_data); %extract sound from log data.

end

