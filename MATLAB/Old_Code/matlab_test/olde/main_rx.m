close all;
clear;
clc;

%Initialize variables

fs=44100; %Sampling frequency

Nb=1000; %Number of bits

%Pull out info from sensor
names=list_sensor_log_files_on_sdcard;
filename = char(names.filenames(end)); % Char converts cell to string
copy_file_from_sdcard_to_working_directory(filename);
log_data=get_log_data_from_FrameWork(filename); 
r=extract_sound_from_log_data(log_data); %received sequence


save('rx_signal.mat','r');

%%
figure();
t = [0:(length(r)-1)]/fs;
plot(t,r)



%%

%----- Demodulate----------------
FSK_demodulate(r,fs);

%--------------------------------




