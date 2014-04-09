%Transmit test applying window and guard time between symbols

close all;
clear;
clc;

%Initialize variables

fs=44100; %Sampling frequency
Nb=1000; %Number of bits to transmit

data = round(rand(1,Nb)); % Generate bits randomly
dlmwrite ('data.txt',data); %Save bits on a txt file. Why?
save('data.mat','data');


Tb=50/fs;
t =0.001;
length_ts=20;
length_gb=10;
f1=2500; %transmit 1
f2=5000; %transmit 0
nr_samples_bit=floor(t*fs);
nr_samples_period=floor(Tb*fs);

gband = round(rand(1,length_gb));
tsequence = round(rand(1,length_ts));
save('tsequence.mat','tsequence')
bit_stream=[gband tsequence data];

window=hann(nr_samples_bit);
delta=150;


%Modulation
tx_signal=[];
tx_temp=[];
tx_short=[];
tx_guard=zeros(1,floor(Tb*fs)-floor(t*fs));
pulse=[];
for(k=1:length(bit_stream))
    b=bit_stream(k);
    switch b
        case 0
            fn = [(f2-delta)*2/fs (f2+delta)*2/fs];
        case 1
            fn = [(f1-delta)*2/fs (f1+delta)*2/fs];
    end
    pulse=fir1(nr_samples_bit-1,fn,window);
    tx_temp = ones(1,nr_samples_bit);
    tx_short = tx_temp .* pulse;
    tx_temp = [tx_short tx_guard];
    tx_signal=[tx_signal tx_temp];
    pulse=0;
end

length(tx_signal)
tx_signal = tx_signal / (max(abs(tx_signal))+0.01);
wavwrite(tx_signal, fs, 'testsound.wav');
copy_file_from_working_directory_to_sdcard( 'testsound.wav' );

create_file_of_shorts('test_signal.dat',tx_signal*2^14);

copy_file_from_working_directory_to_sdcard( 'test_signal.dat' );
    
    
    
            
    







