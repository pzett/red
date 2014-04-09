close all;
clear;
clc;

%Initialize variables


%% Random data
fs=44100; %Sampling frequency
Nb=1000; %Number of bits to transmit
data = round(rand(1,Nb)); % Generate bits randomly
%data=markovsource(0.05,0.05,Nb); %Generate pseudo random bits.

% %% Audio File  %currently too heavy to handle with bin-fsk
% % Note: comment lines above (random data)
% [data,fs]=wavread('testsound.wav');
% data=data'; %to have row vector

%% Store signal
%dlmwrite ('data.txt',data); %Save bits on a txt file. Why?
save('data.mat','data')

%% ----------Coding----------------




%% ----------Modulation------------

%mod_signal = FSK_modulation(data,fs);  %

mod_signal = MFSK_modulation(data);

% ----------------------------------

%mod_signal = mod_signal/(max(abs(mod_signal) + 0.01));


save('mod_signal.mat','mod_signal'); % Save modulated signal

%% ---------- File transfer to phone
%wavwrite(mod_signal, fs, 'mod_signal.wav');
create_file_of_shorts('test_signal.dat',mod_signal*2^14)
copy_file_from_working_directory_to_sdcard( 'test_signal.dat' );
