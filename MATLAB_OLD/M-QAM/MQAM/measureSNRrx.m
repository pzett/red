%Set up variables and workspace.
close all;
clear;
clc;
load('sine.mat')

fs=44100;
names=list_sensor_log_files_on_sdcard;%grabs list of .csv files on phone
filename = char(names.filenames(end)); % Char converts cell to string
copy_file_from_sdcard_to_working_directory(filename);%copy file to folder
log_data=get_log_data_from_FrameWork(filename); %grab log data
r=extract_sound_from_log_data(log_data); %extract sound from log data.

% Crop the signal 
offset = 2
first_samp = find_threshold(r) - offset
last_samp = first_samp + length(sine);
r_sine = r(first_samp+10000:last_samp);
r_sine = r_sine/max(abs(r_sine));
sine = sine(10000:end);

%%
clf
N = 1;
K = 100;
plot(r_sine(N:N+K))
hold on
plot(sine(N:N+K),'r')

%%

residual = r_sine - sine';

%%


