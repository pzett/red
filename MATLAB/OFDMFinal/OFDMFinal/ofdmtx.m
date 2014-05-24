
%% OFDM Functions to transfer files between two Android devices
%% Transmitter Side
%Author : Red Group - Francisco Rosario (frosario@kth.se)
%This script creates and modulates binary data into OFDM symbols and
%creates the corresponding OFDM signal. It then uploads the file in format of
%shorts to all connected devices. 
%The binary source may be either random or from a file.
%This function is to be used with ofdmrx
%% Set up variables and workspace.
addpath('./functions/')
set_up(); %clear previous variables
clear;
%% Initialize needed variables

%OFDM Parameters
A = 1; % constellation amplitude, does not work
FS = 2048; % length of FFT/IFFT
fc = 9000; % carrier frequency
P = 6; %length of prefix
S = 6; %length of suffix

Nc = 800; %number of active subcarriers
fs = 44100; %Sampling frequency
intlv = 1; % use scrambler ?
%Constellation 
levels = 3; %numbers of levels in constellation /1->4,2->16,3->64-QAM) 
window = 0;

asym = 1; % use asymmetric number of active carriers around carrier frequency
high = 460; % Parameter used in asymmetric OFDM

%Training sequence, guard band and pilots
ts_length=8*Nc; % (in symbols) length of training sequence
gb_length=8*Nc; % (in symbols) length of guard band
gb_end_length = 6*Nc;
pilot = 0; % use pilots in the middle of transmission? % this might not work. channel is time-invariant, no need to use. but still it is implemented as a reference
pilot_int = 12*Nc*2*levels; %(in bits) how many bits should be sent before pilot insertion
ts_pilot_length = 6*Nc; %(in symbols) pilot length to reestimate the channel

%Channel Coding usage
code = 0; %do you want to use channel coding?
rate = 9/10; %rate usage of the code


use_menu = 1;
%% Random or file Transmission ?
file = create_menu(use_menu,pilot,code,intlv);
Nb =256000*8 ; %random transmission size (in bits)

%% Generate data, training sequence and guard band
[gb,gb_end,ts,data_sent,data_encoded,Nb] = generate_data(gb_length,gb_end_length,ts_length,Nb,levels,Nc,file,code,rate,intlv);


%% Insert pilots
[data_sent_pilot , ts_pilot] = generate_pilots(data_sent,pilot_int,ts_pilot_length,Nb,pilot,levels);


%% Merge Bits from guard band, training seq. and data
if(code || intlv)
    bit_stream = [gb' ts' data_encoded' gb_end']; % merge the data
else
    bit_stream = [gb' ts' data_sent_pilot' gb_end']; % merge the data
end

L=length(bit_stream); %raw data length



%% Map into constellation
[mconst, mconst_ts] = MQAM_map(bit_stream,L,gb_length,ts_length, levels, Nc ,A);


%% Initialize OFDM modulation
if(asym)
    data_OFDM = modulate_OFDM_asym(mconst,Nc,FS,P,S,high,window); %asymetric OFDM modulation
else
    data_OFDM = modulate_OFDM(mconst,Nc,FS,P,S,window); %symmetric OFDM modulation
    %data_OFDM = OFDMmod_window(unmod_data,P,S); % do the fft and insert cyclic prefix
end



%% Upconvert to carrier frequency
t = 0 : 1 / fs : ( length(data_OFDM)-1 ) / fs;
up_signal = real(transpose(data_OFDM).*exp(1i*2*pi*fc*t)); % samples must be real

%normalize signals to amplitude, save and plot
mod_signal=up_signal/(max(abs(up_signal)+0.001));
[ ts_mod ] = save_and_plot(FS,S,P,up_signal,mod_signal,fs,Nc,gb_length,ts_length,Nb,gb_end_length,levels);
save('OFDM.mat','Nb','levels','fc','data_sent','gb_length','A','mod_signal','P','S','Nc','FS','high','file','rate','code','data_encoded','asym','intlv');
save('ts_mod.mat','ts_mod','mconst_ts','ts','ts_pilot','ts_length','pilot','pilot_int','ts_pilot_length' );

