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
Nb=14000; %Number of bits to transmit.
  
  if mod(Nb,2)~= 0
      error('Use a number of bits that is divisible by 2');
  end

%% -------- Binary FSK parameters-----------
%uncomment to use BFSK
% Tb = 25/fs; %Bit period
% % Frequency component for bit 1
% f1 = 1/(3*Tb);%5000+4*fs/200; 
% % Frequency component for bit 0 
% f2 = 1/(6*Tb);
% gb_length=10; %length of guard band
% ts_length=20; %length of training sequence
% save('FSK.mat','f1','f2','Tb','gb_length','ts_length')
% bits_per_symbol = 1;

%% --------- MFSK paarameters with Hanning window -------------
Tb=75/fs;  %Bit/symbol period + guard period between symbols
t = Tb;    %Bit/symbol period (t=Tb to set guard period to 0)
M=4;       %Number of frequencies to transmit over. 
f=zeros(1,M); %vector containing the frequencies to be used.
alfa=zeros(1,M); %variable to construct the working frequencies
multiple=60; %sampling frequency is a multiple of the used frequencies.
for(m=1:M)
    alfa(m)=(m-1)*fs/multiple; % different frequencies are separated by
    f(m)=fs/multiple+alfa(m);  % fs/multiple
end

bits_per_symbol = log2(M); %bits transmitted per symbol

% FDM
f1 = f;
f2 = f + 4/60*fs;
f3 = f + 8/60*fs;
f4 = f + 12/60*fs;
f5 = f + 16/60*fs;
f6 = f + 20/60*fs;
f7 = f + 24/60*fs;

save('FDM.mat','f1','f2','f3','f4','f5','f6','f7')

save('MFSK.mat','f','Tb','t','bits_per_symbol','M') %save variables for 
                                                    %testing purposes    


%% ------------Pilot signal-----------
% tsequence =[0 0 0 0 1 1 0 1]; %length 8
% tsequence =[0 0 1 1 0 0 0 0 0 1 0 1]; %length 12
% tsequence =[0 0 0 0 0 1 1 0 0 1 1 0 1 0 1 1]; %length 16
% tsequence =[ 0 0 0 1 0 0 0 1 1 1 1 1 0 0 1 0 1 1 0 1]; %length 20
% tsequence =[0 0 0 1 1 1 1 1 1 0 0 1 0 0 0 0 1 1 0 0 1 0 1 0]; %length 24
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
%data=markovsource(0.05,0.05,Nb); %Generate pseudo random bits.



% Multiplex data for FDM
l = length(data)/7;
DATA = zeros(7,l);

for k=1:l
    DATA(k) = data(k);
end

data = DATA;




% ----------Coding----------------
%   s_name='data5kB.txt'; % name of source file
%   encodeASCII(s_name,'encoded.bin'); 
%   bin_fid=fopen('encoded.bin'); 
%   data=fscanf(bin_fid,'%1d'); %binary form
%   data=data';
%   fclose(bin_fid); %stop the pointers
%   Nb = length(data)

% ----------Modulation------------
[mod_pilot mod_ts] = pilot_modulator(tsequence,Nb,gb_length,Tb,fs,f1_ts,f2_ts,f3_ts,f4_ts,d_length);
save('mod_ts.mat','mod_ts')

%mod_signal = FSK_modulation(data,fs,f1,f2,Tb,gb_length,tsequence);  
%mod_signal = MFSK_modulation(data);
%mod_signal = MFSKwindow_modulation(data, fs,f,Tb,gb_length,t,tsequence);


% MFSK with FDM
mod_signal_1 = MFSKwindow_modulation(DATA(1,:), fs,f1,Tb,gb_length,t,tsequence);
mod_signal_2 = MFSKwindow_modulation(DATA(2,:), fs,f2,Tb,gb_length,t,tsequence);
mod_signal_3 = MFSKwindow_modulation(DATA(3,:), fs,f3,Tb,gb_length,t,tsequence);
mod_signal_4 = MFSKwindow_modulation(DATA(4,:), fs,f4,Tb,gb_length,t,tsequence);
mod_signal_5 = MFSKwindow_modulation(DATA(5,:), fs,f5,Tb,gb_length,t,tsequence);
mod_signal_6 = MFSKwindow_modulation(DATA(6,:), fs,f6,Tb,gb_length,t,tsequence);
mod_signal_7 = MFSKwindow_modulation(DATA(7,:), fs,f7,Tb,gb_length,t,tsequence);
mod_signal = 1/7*(mod_signal_1+mod_signal_2 + mod_signal_3 + mod_signal_4 + mod_signal_5 + mod_signal_6 + mod_signal_7);

mod_signal = [mod_pilot mod_signal]; %concatenate

% -----------Save signals and parameters----------
save('tx_file.mat','fs','Nb','data','mod_signal'); % Save modulated signal



% ---------- File transfer to phone----------
%wavwrite(mod_signal, fs, 'mod_signal.wav');
create_file_of_shorts('test_signal.dat',mod_signal*2^14)
copy_file_from_working_directory_to_sdcard( 'test_signal.dat' );

mod_signal_length = length(mod_signal)/fs; % Length of modulated signal in seconds

fprintf('Modulated signal: %g seconds long \n',mod_signal_length)
