%Transmit test applying window and guard time between symbols

close all;
clear;
clc;

%Initialize variables

fs=44100; %Sampling frequency
Nb=10000; %Number of bits to transmit

data = round(rand(1,Nb)); % Generate bits randomly
dlmwrite ('data.txt',data); %Save bits on a txt file. Why?
save('data.mat','data');


Tb=50/fs;
t =0.001;
length_ts=200;
length_gb=200;
nr_samples_bit=floor(t*fs);
nr_samples_period=floor(Tb*fs);
M=4;



deltafc=1/Tb;
f=zeros(1,M);
alfa=zeros(1,M); %variable to construct the working frequencies

%fc=5000; %central frequency
% for(m=1:M)
%     alfa(m)=2*m-1-M;
%     f(m)=fc+alfa(m)*deltafc;
% end
% disp('frequencies:'); f

%compute integer divisors of sampling frequency.
multiple=24;
for(m=1:M)
    alfa(m)=(m-1)*fs/multiple;
    f(m)=fs/multiple+alfa(m);
end
f
    

gband = round(rand(1,length_gb));
tsequence = round(rand(1,length_ts));
save('tsequence.mat','tsequence')
bit_stream=[gband tsequence data];

window=hann(nr_samples_bit);
delta=10;


%Modulation
tx_signal=[];
tx_temp=[];
tx_short=[];
tx_guard=zeros(1,floor(Tb*fs)-floor(t*fs));
pulse=[];
symbol=zeros(1,2);
for j=1:log2(M):(length(bit_stream))
    symbol_b=[bit_stream(j) bit_stream(j+1)];
    symbol_d=bi2de(symbol_b,'left-msb');
    switch symbol_d
        case 0
            fn = [(f(1)-delta)*2/fs (f(1)+delta)*2/fs];
        case 2
            fn = [(f(2)-delta)*2/fs (f(2)+delta)*2/fs];
        case 3
            fn = [(f(3)-delta)*2/fs (f(3)+delta)*2/fs];
        case 1 
            fn = [(f(4)-delta)*2/fs (f(4)+delta)*2/fs];

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
