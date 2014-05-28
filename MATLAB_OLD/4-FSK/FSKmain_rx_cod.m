%% Main function for receiver device and for simulation purposes %%
%Loads information from transmitter side to compare with received sequence%
%retrieved from phone. Demodulates received signal and calculates BER and %
%the rate of the transmission.

close all;
clear;
clc;
fclose('all');

% Load parameters from TX
load('tx_file.mat');
load('pilot.mat')
load('MFSK.mat');

%%
%Pull out info from sensor
names=list_sensor_log_files_on_sdcard;%grabs list of .csv files on phone
filename = char(names.filenames(end)); % Char converts cell to string
copy_file_from_sdcard_to_working_directory(filename);%copy file to folder
log_data=get_log_data_from_FrameWork(filename); %grab log data
r=extract_sound_from_log_data(log_data); %extract sound from log data.

%------Syncronization--------------
load('mod_ts.mat')

[k_start nr_of_bits] = pilot_demodulator(r,mod_ts,gb_length,Tb,fs,f1_ts,f2_ts,d_length);

nr_of_samples = 1/2*nr_of_bits*Tb*fs; %number of samples expected to be received 

fprintf('Expected number of bits to be received: %d \n',nr_of_bits);

r=-r(k_start:k_start+nr_of_samples);%crop r to the data containing sequence

%----- Demodulation----------------
decision=goertzel2(f(1),f(2),f(3),f(4),fs,Tb*fs,r);%decide using Goertzel Algorithm
%---------Plots--------------------------
%%
errors = sum(decision~=data);

BER = errors/(Nb)*100;

rate = 2/Tb;

fprintf('Transmission with %g bits/s and BER %g%% \n',rate,BER)

%% Plot the spectrums and transmitted and received sequences (part of)
figure(2)
k_plot = 250; % Number of samples in time domain plot
pilot_samples = gb_length*Tb*fs + length(mod_ts) + d_length*Tb*fs; % Number of samples corresponding to guard bits in modulated signal
t = [0:k_plot-1]/fs;

subplot(2,2,1)
plot(t,mod_signal(pilot_samples:pilot_samples+k_plot-1)) % Plot transmitted signal in time domain
xlabel('t [s]')
title('Transmitted signal')

subplot(2,2,3)
plot(t,r(1:k_plot)) % Plot received signal
xlabel('t [s]')
title('Received signal')

subplot(2,2,2)
pwelch(mod_signal(pilot_samples:end))

subplot(2,2,4)
pwelch(r(1:nr_of_samples))

figure(3)

subplot(2,1,1)
spectrogram(mod_signal(pilot_samples:pilot_samples+k_plot-1),Tb*fs,Tb*fs-1,1024,fs,'yaxis');
title('Spectrogram of transmitted signal')
%ylim([0 12000])
subplot(2,1,2)
spectrogram(r(1:k_plot),Tb*fs,Tb*fs-1,1024,fs,'yaxis');
title('Spectrogram of received signal')
%ylim([0 12000])







