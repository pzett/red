close all;
clear;
clc;

%Initialize variables

fs=44100; %Sampling frequency

Tb=50/fs; %Bit period

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


tsequence=importdata('tsequence.mat');
data=importdata('data.mat');

t = 0 : 1/fs : Tb-1/fs; %time for one bit
names=list_sensor_log_files_on_sdcard;
filename = char(names.filenames(end)); % Char converts cell to string
copy_file_from_sdcard_to_working_directory(filename);
log_data=get_log_data_from_FrameWork(filename); 
r=extract_sound_from_log_data(log_data);
%%
threshold=100; %define threshold to start detection
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

decision=goertzel2(f(1),f(2),f(3),f(4),fs,Tb*fs,r);

sum(decision(1:length([tsequence data]))~=([tsequence data]))