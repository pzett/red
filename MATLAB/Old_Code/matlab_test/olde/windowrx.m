%Transmit test applying window and guard time between symbols

close all;

%Initialize variables

fs=44100; %Sampling frequency
Nb=1000; %Number of bits to transmit

data=importdata('data.mat');
tsequence=importdata('tsequence.mat');
Tb=50/fs;
t =0.001;
length_ts=20;
length_gb=10;
f1=2500; %transmit 1
f2=5000; %transmit 0
nr_samples_bit=floor(t*fs);
nr_samples_period=floor(Tb*fs);



%Choose way to receive sequence
names=list_sensor_log_files_on_sdcard;
filename = char(names.filenames(end)); % Char converts cell to string
copy_file_from_sdcard_to_working_directory(filename);
log_data=get_log_data_from_FrameWork(filename); 
r=extract_sound_from_log_data(log_data);
%%
%r=importdata('rx_sequence.mat');

% [r,fs]=wavread('testsound.wav');
% length(r);

%Synchronization

%remove silent period
threshold=100; %define threshold to start detection

for(k=1:length(r))
    if(r(k)>threshold)
        k_start=k;
        break
    end
end


%start detecting -> detect training sequence
%modulate training sequence

tx_ts=[];
tx_temp=[];
tx_short=[];
tx_guard=zeros(1,floor(Tb*fs)-floor(t*fs));
pulse=[];
window=hann(nr_samples_bit);
delta=150;
for(k=1:length(tsequence))
    b=tsequence(k);
    switch b
        case 0
            fn = [f2-delta f2+delta]*2/fs;
        case 1
            fn = [f1-delta f1+delta]*2/fs;
    end
    pulse=fir1(nr_samples_bit-1,fn,window);
    tx_temp = ones(1,nr_samples_bit);
    tx_short = tx_temp .* pulse;
    tx_temp = [tx_short tx_guard];
    tx_ts=[tx_ts tx_temp];
    pulse=0;
end

%correlate with received singal
% x(:,1)=tx_ts;
% t0=k_start;
% t1=floor(length(r(k_start:end))/2);
% length_ts=length(tx_ts);
% 
% for i=t0:t1
% x(:,2)=r(i:length_ts+i-1);
% R=corrcoef(x);
% R_out1(i)=R(1,2);
% if R(1,2)>0.99   %set a threshold to jump out the circulation
%     t_start = i; 
%     break
% end
% end


% verify where signal starts
block_length=5000; %block to be analyzed

r_yts=xcorr(r(k_start:k_start+block_length),tx_ts);

[peak,offset]=max(abs(r_yts)); %find peak of cross correlation

k_start = k_start + (offset - (length(r_yts)+1)/2) %only the positive ...
                                                    %matters
%t_start                                                    
%

%Send to demodulator.

decision=goertzel(f1,f2,fs,Tb*fs,r(k_start:end));

sum(decision(1:length([tsequence data]))~=[tsequence data])





