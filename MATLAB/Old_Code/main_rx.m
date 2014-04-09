close all;
clear;
clc;
fclose('all');

%Initialize variables
fs = 44100;
load('tx_file.mat')
load('tsequence.mat')
%load('FSK.mat')
load('MFSK.mat')

%Pull out info from sensor
names=list_sensor_log_files_on_sdcard;
filename = char(names.filenames(end)); % Char converts cell to string
copy_file_from_sdcard_to_working_directory(filename);
log_data=get_log_data_from_FrameWork(filename); 
r=extract_sound_from_log_data(log_data); %received sequence
%%
%----- Demodulation----------------
%[decision k_start] = FSK_demodulation(r,data,fs,f1,f2,Tb,gb_length,ts_length,tsequence);
[decision k_start] = MFSKwindow_demodulation(r,data,fs,f,Tb,gb_length,t,tsequence);


%--------Decoder -----------------
%    bin_fid2=fopen('decoded.bin','w');
%    fprintf(bin_fid2,'%1d',decision);
%    fclose(bin_fid2);
%    decodeASCII('decoded.bin','rcvd_msg.txt');

%---------Plots--------------------------
%%
errors = sum(decision(1:length([tsequence data]))~=[tsequence data]);

BER = errors/Nb*100;

rate = bits_per_symbol/Tb;

fprintf('Transmission with %g bits/s and BER %g%% \n',rate,BER)

%%
k_plot = 500; % Number of samples in time domain plot
gb_samples = 1/log2(M)*gb_length*Tb*fs; % Number of samples corresponding to guard bits in modulated signal
t = [0:k_plot-1]/fs;

subplot(2,2,1)
plot(t,mod_signal(gb_samples:gb_samples+k_plot-1)) % Plot transmitted signal in time domain
xlabel('t [s]')
title('Transmitted signal')

subplot(2,2,3)
plot(t,r(k_start:k_start+k_plot-1)) % Plot received signal
xlabel('t [s]')
title('Received signal')

subplot(2,2,2)
pwelch(mod_signal)

subplot(2,2,4)
pwelch(r)








