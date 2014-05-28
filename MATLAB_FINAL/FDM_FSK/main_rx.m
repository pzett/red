%% Main function for receiver device and for simulation purposes %%
%Loads information from transmitter side to compare with received sequence%
%retrieved from phone. Demodulates received signal and calculates BER and %
%the rate of the transmission.

close all;
clear;
clc;
fclose('all');

%Initialize variables
fs = 44100;
load('tx_file.mat')
load('pilot.mat')
%load('FSK.mat')
load('MFSK.mat')
load('FDM.mat')

%Pull out info from sensor
names=list_sensor_log_files_on_sdcard;%grabs list of .csv files on phone
filename = char(names.filenames(end)); % Char converts cell to string
copy_file_from_sdcard_to_working_directory(filename);%copy file to folder
log_data=get_log_data_from_FrameWork(filename); %grab log data
r=extract_sound_from_log_data(log_data); %extract sound from log data.
%%
%------Syncronization--------------
load('mod_ts.mat')

[k_start nr_of_bits] = pilot_demodulator(r,mod_ts,gb_length,Tb,fs,f1_ts,f2_ts,d_length);

nr_of_samples = 1/2*nr_of_bits*Tb*fs/7; %number of samples expected to be received 

fprintf('Expected number of bits to be received: %d \n',nr_of_bits);

r=r(k_start:k_start+nr_of_samples);%crop r to the data containing sequence

%----- Demodulation----------------
%[decision k_start] = FSK_demodulation(r,data,fs,f1,f2,Tb,gb_length,ts_length,tsequence);
%[decision ~] = MFSKwindow_demodulation(r,data,fs,f,Tb,gb_length,t,tsequence);
%decision=goertzel2(f(1),f(2),f(3),f(4),fs,Tb*fs,r);%decide using Goertzel Algorithm

%---------FDM demoulation----------------
decision1=goertzel2(f1(1),f1(2),f1(3),f1(4),fs,Tb*fs,r);
decision2=goertzel2(f2(1),f2(2),f2(3),f2(4),fs,Tb*fs,r);
decision3=goertzel2(f3(1),f3(2),f3(3),f3(4),fs,Tb*fs,r);
decision4=goertzel2(f4(1),f4(2),f4(3),f4(4),fs,Tb*fs,r);
decision5=goertzel2(f5(1),f5(2),f5(3),f5(4),fs,Tb*fs,r);
decision6=goertzel2(f6(1),f6(2),f6(3),f6(4),fs,Tb*fs,r);
decision7=goertzel2(f7(1),f7(2),f7(3),f7(4),fs,Tb*fs,r);
%-------demultiplexing-----------
v=[];
for n=1:length(decision1);
    v=[v decision1(n) decision2(n) decision3(n) decision4(n) decision5(n) decision6(n) decision7(n)];
end

%--------Decoder -----------------
decoder_output=v;

%----Decode into ASCII file--------------
%    bin_fid2=fopen('decoded.bin','w');
%    fprintf(bin_fid2,'%1d',decision);
%    fclose(bin_fid2);
%    decodeASCII('decoded.bin','rcvd_msg.txt');

%---------Plots--------------------------
%%
% errors = sum(decoder_output(1:length(data_raw))~=data_raw(:,:));
errors1 = sum(decision1(1:length(data))~=data(1,:));
errors2 = sum(decision2(1:length(data))~=data(2,:));
errors3 = sum(decision3(1:length(data))~=data(3,:));
errors4 = sum(decision4(1:length(data))~=data(4,:));
errors5 = sum(decision5(1:length(data))~=data(5,:));
errors6 = sum(decision6(1:length(data))~=data(6,:));
errors7 = sum(decision7(1:length(data))~=data(7,:));
errors = errors1 + errors2 + errors3 + errors4 + errors5 + errors6 + errors7;
BER = errors/Nb*100;

rate =7*bits_per_symbol/Tb;



fprintf('Transmission with %g bits/s and BER %g%% \n',rate,BER)

%% Plot the spectrums and transmitted and received sequences (part of)
figure(2)
k_plot = 500; % Number of samples in time domain plot
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
pwelch(mod_signal)

subplot(2,2,4)
pwelch(r)








