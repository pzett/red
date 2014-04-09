close all;
clear;
clc;

%Initialize variables

fs=44100; %Sampling frequency

Tb=200/fs; %Bit period

Nb=1000; %Number of bits to transmit

fc=3000; %central frequency

M=4;

deltafc=1/Tb;
f=zeros(1,M);
alfa=zeros(1,M); %variable to construct the working frequencies
for(m=1:M)
    alfa(m)=2*m-1-M;
    f(m)=fc+alfa(m)*deltafc;
end

data = round(rand(1,Nb)); % Generate bits randomly
dlmwrite ('dataFSK.txt',data); %Save bits on a txt file

gb_length=10; %length of guard band
ts_length=20; %length of training sequence
guard=round(rand(1,gb_length)); %generate guard band
tsequence=round(rand(1,ts_length)); %generate tsequence
bit_stream = [guard tsequence data]; %merge the bits together

% Time for one bit
t = 0 : 1/fs : Tb-1/fs;

time = []; % complete time
FSK_signal = []; %Signal to transmit
 
t_tot=t; %auxiliary variable

%Generate FSK_signal
for ii = 1:log2(M):length(bit_stream)
    FSK_signal = [FSK_signal (bit_stream(ii)==0 && bit_stream(ii+1)==0)*cos(2*pi*f(1)*t)+...
                        (bit_stream(ii)==1 && bit_stream(ii+1)==0)*cos(2*pi*f(2)*t)+...
                        (bit_stream(ii)==1 && bit_stream(ii+1)==1)*cos(2*pi*f(3)*t)+...
                        (bit_stream(ii)==0 && bit_stream(ii+1)==1)*cos(2*pi*f(4)*t)];
    time=[time t_tot];
    t_tot=t_tot+Tb;
         
end

%Send signal through channel%

snr=60; %Define SNR in dB
y = awgn(FSK_signal,snr,'measured'); % add noise


%Received signal
sigma2=0.02; %std deviation of noise

r=[sigma2.*randn(2000,1)' y ];%0*sigma2.*randn(2000,1)']; %merge with noise

threshold=0.5; %define threshold to start detection

for(k=1:length(r))
    if(r(k)>threshold)
        k_start=k;
        break
    end
end

%modulate training sequence to verify cross correlation
modu_ts=[];
for ii = 1:log2(M):length(tsequence)
    
    modu_ts = [modu_ts (tsequence(ii)==0 && tsequence(ii+1)==0)*cos(2*pi*f(1)*t)+...
                       (tsequence(ii)==1 && tsequence(ii+1)==0)*cos(2*pi*f(2)*t)+...
                       (tsequence(ii)==1 && tsequence(ii+1)==1)*cos(2*pi*f(3)*t)+...
                       (tsequence(ii)==0 && tsequence(ii+1)==1)*cos(2*pi*f(4)*t)];
                   
                        
end

% verify where signal starts by using correlation
block_length=4096; %block to be analyzed

r_yts=xcorr(r(k_start:k_start+4096),modu_ts);

[peak,offset]=max(abs(r_yts)); %find peak of cross correlation

k_start = k_start + (offset - (length(r_yts)+1)/2); %only the positive part of the autocorrelation
                                                    %matters
r=r(k_start:end);

decision=goertzel2(f(1),f(2),f(3),f(4),fs,88,r);

sum(decision~=([tsequence data]))


    
    
    
