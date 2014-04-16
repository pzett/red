%% Main function for transmitter device and for simulation purposes %%
%Able to choose transmission mode (MFSK or BFSK), choose the frequencies,
%bit period, length of training sequence and guard bits and number of bits
%allocated containing the number of bits to be transmitted (size of file)%
%% 
%Set up variables and workspace.
close all;
clear;
clc;
fclose('all');

%Initialize variables
fs=44100; %Sampling frequency
Nb=10000; %Number of bits to transmit.

%% --------- MFSK paarameters with Hanning window -------------
Tb=35/fs;  %Bit/symbol period + guard period between symbols
t = Tb;    %Bit/symbol period (t=Tb to set guard period to 0)
M=4;       %Number of frequencies to transmit over. 
f=zeros(1,M); %vector containing the frequencies to be used.
alfa=zeros(1,M); %variable to construct the working frequencies

multiple=24; %sampling frequency is a multiple of the used frequencies.
f = [1/multiple 4/multiple 7/multiple 10/multiple]*fs;
% for(m=1:M)
%     alfa(m)=(m-1)*fs/multiple; % different frequencies are separated by
%     f(m)=fs/multiple+alfa(m);  % fs/multiple
% end

bits_per_symbol = log2(M); %bits transmitted per symbol


save('MFSK.mat','f','Tb','t','bits_per_symbol','M') %save variables for testing purposes  


%% ------------Pilot signal-----------
ts_length=100; % Number of training sequence bits
tsequence = round(rand(1,ts_length)); %Generate tsequence randomly

%Choose frequencies for guard band and training sequence (modulated as
%BFSK
%(they should be different for xcorr purposes)
f1_ts = 4/multiple*fs; % Frequencies of FSK modulated pilot signal
f2_ts = 1/multiple*fs;
f3_ts = 2500; % Frequencies of FSK modulated training sequence
f4_ts = 4500;
gb_length=100; %guard band length
d_length = 17; %bits allocated to transmit the length of the file.

save('pilot.mat','f1_ts','f2_ts','gb_length','d_length');


% ---------Generate data---------
data = round(rand(1,Nb)); % Generate bits randomly for data

% ----------Modulation------------
[mod_pilot mod_ts] = pilot_modulator(tsequence,Nb,gb_length,Tb,fs,f1_ts,f2_ts,f3_ts,f4_ts,d_length);
save('mod_ts.mat','mod_ts')

mod_signal = MFSKwindow_modulation(data,fs,f,Tb,gb_length,t,tsequence);

mod_signal = [mod_pilot mod_signal]; %concatenate

% -----------Save signals and parameters----------
save('tx_file.mat','fs','Nb','data','mod_signal'); % Save modulated signal

% ---------- File transfer to phone----------
create_file_of_shorts('test_signal.dat',mod_signal*2^14)
copy_file_from_working_directory_to_sdcard( 'test_signal.dat' );

mod_signal_length = length(mod_signal)/fs; % Length of modulated signal in seconds

fprintf('Modulated signal: %g seconds long \n',mod_signal_length)
