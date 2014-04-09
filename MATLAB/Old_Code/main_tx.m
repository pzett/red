close all;
clear;
clc;
fclose('all');

%Initialize variables
fs=44100; %Sampling frequency
Nb=5000;%Number of bits to transmit
  
  if mod(Nb,2)~= 0
      error('Use a number of bits that is divisible by 2');
  end

%% -------- Binary FSK parameters-----------
% % Frequency component for bit 1
% f1 = 5000+4*fs/200; 
% % Frequency component for bit 0 
% f2 = 5000;
% Tb=200/fs; %Bit period
% gb_length=10; %length of guard band
% ts_length=20; %length of training sequence
% save('FSK.mat','f1','f2','Tb','gb_length','ts_length')
% bits_per_symbol = 1;

%% --------- MFSK paarameters with Hanning window -------------
Tb=50/fs;
t = 0.9*Tb;    %Dutty cycle?
gb_length=200; %guard band length
M=4;
f=zeros(1,M);
alfa=zeros(1,M); %variable to construct the working frequencies
multiple=24;
for(m=1:M)
    alfa(m)=(m-1)*fs/multiple;
    f(m)=fs/multiple+alfa(m);
end
bits_per_symbol = log2(M);

save('MFSK.mat','f','Tb','gb_length','t','bits_per_symbol','M')

   


%% ------------Training sequence-----------
% tsequence =[0 0 0 0 1 1 0 1]; %length 8
% tsequence =[0 0 1 1 0 0 0 0 0 1 0 1]; %length 12
% tsequence =[0 0 0 0 0 1 1 0 0 1 1 0 1 0 1 1]; %length 16
% tsequence =[ 0 0 0 1 0 0 0 1 1 1 1 1 0 0 1 0 1 1 0 1]; %length 20
% tsequence =[0 0 0 1 1 1 1 1 1 0 0 1 0 0 0 0 1 1 0 0 1 0 1 0]; %length 24
ts_length=200; % 200 bits for MFSK
tsequence = round(rand(1,ts_length));

save('tsequence.mat','tsequence');


% ---------Generate data---------
%data = round(rand(1,Nb)); % Generate bits randomly
data=markovsource(0.05,0.05,Nb); %Generate pseudo random bits.


% ----------Coding----------------
%   s_name='data5kB.txt'; % name of source file
%   encodeASCII(s_name,'encoded.bin'); 
%   bin_fid=fopen('encoded.bin'); 
%   data=fscanf(bin_fid,'%1d'); %binary form
%   data=data';
%   fclose(bin_fid); %stop the pointers



% ----------Modulation------------

%mod_signal = FSK_modulation(data,fs,f1,f2,Tb,gb_length,tsequence);  
%mod_signal = MFSK_modulation(data);
mod_signal = MFSKwindow_modulation(data, fs,f,Tb,gb_length,t,tsequence);

% -----------Save signals and parameters----------
save('tx_file.mat','fs','Nb','data','mod_signal'); % Save modulated signal



% ---------- File transfer to phone
%wavwrite(mod_signal, fs, 'mod_signal.wav');
create_file_of_shorts('test_signal.dat',mod_signal*2^14)
%copy_file_from_working_directory_to_sdcard( 'test_signal.dat' );

mod_signal_length = length(mod_signal)/fs; % Length of modulated signal in seconds

fprintf('Modulated signal: %g seconds long \n',mod_signal_length)
