% %%%%
% % Code for simulating BFSK scheme through non-distorting AWGN channel
% % Variables:
%     Tb -> Bit period  
%     Nb -> Number of bits to be transmitted.
%     gb_length,ts_length, length_data_b -> Bits containing guard band, 
%                                           training sequence and 
%                                           length of file in bits
%     Modulation is done by simply choosing 2 frequencies f1 and f2
%     separated by 2/Tb so that they are orthogonal. 
%       0 -> f2
%       1 -> f1

%     Demodulation is done by various methods:
%       Correlators:
%           Coherent and Noncoherent -> good to evaluate performance but
%           heavy in terms of comuputation
%       Goertzel Algorithm:
%           Algorithm to detect tones present in the FSK system

%     Synchronization Algorithm
        %Makes use of training sequence, does crosscorrelation between
        %received and training sequence and evaluates maximum to calculate
        %offset       
%     


close all;
clear;
clc;

%Initialize variables

fs=44100; %Sampling frequency

Tb=88/fs; %Bit period

Nb=1000; %Number of bits to transmit

data = round(rand(1,Nb)); % Generate bits randomly
dlmwrite ('dataFSK.txt',data); %Save bits on a txt file

gb_length=10; %length of guard band
ts_length=20; %length of training sequence
guard=round(rand(1,gb_length)); %generate guard band
tsequence=round(rand(1,ts_length)); %generate tsequence
length_data_b=20; %allocate 20 bits for file size.
b=de2bi(Nb,'left-msb'); %convert to binary 
length_stream=[zeros(1,length_data_b-length(b)) b]; %fill with zeros
bit_stream = [guard tsequence length_stream data tsequence guard]; %merge the bits together

save('tsequence.mat','tsequence'); %save tsequence in order to have reference at receiver.

% Define the two frequencies 
% Frequency component for bit 1
f1 = 2500+2*fs/88; 
% Frequency component for bit 0 
f2 = 2500;

% Time for one bit
t = 0 : 1/fs : Tb-1/fs;

time = []; % complete time
FSK_signal = []; %Signal to transmit
 
t_tot=t; %auxiliary variable


%Modulation 

%Generate FSK_signal
for ii = 1:length(bit_stream)
    
    FSK_signal = [FSK_signal (bit_stream(ii)==1)*cos(2*pi*f1*t)+...
                             (bit_stream(ii)==0)*cos(2*pi*f2*t)    ];
   
    time=[time t_tot];
    t_tot=t_tot+Tb;
    
end


%Send signal through channel%

snr=50; %Define SNR in dB
y = awgn(FSK_signal,snr,'measured');

%Received signal
sigma2=0.02; %std deviation of noise

r=[sigma2.*randn(2000,1)' y ];%0*sigma2.*randn(2000,1)']; %merge with noise
r_norm=r/abs(max(r));

threshold=0.5; %define threshold to start detection

%identify beggining of signal
for(k=1:length(r))
    if(r_norm(k)>threshold)
        k_start=k;
        break
    end
end


%modulate training sequence to verify cross correlation
modu_ts=[];
for ii = 1:length(tsequence)
    
    modu_ts = [modu_ts       (tsequence(ii)==1)*cos(2*pi*f1*t)+...
                             (tsequence(ii)==0)*cos(2*pi*f2*t)    ];
           
end


% verify where signal starts
block_length=4096; %block to be analyzed

r_yts=xcorr(r(k_start:k_start+block_length),modu_ts); %crosscorrelation

[peak,offset]=max(abs(r_yts)); %find peak of cross correlation

k_start = k_start + (offset - (length(r_yts)+1)/2); %only the positive ...
                                                    %matters

r=r(k_start:end);

decision=goertzel(f1,f2,fs,88,r);
exp_length = bi2de(decision(ts_length+1:ts_length+length_data_b),'left-msb');
disp('expected length:'); disp(exp_length);

disp('erros for Groetzel algorithm:')
sum(decision(ts_length+length_data_b+1:exp_length+ts_length+length_data_b)~=[data])





%Coherent demodulation with 2 correlators %
multiplier1 = cos(2*pi*f1*t);
multiplier2 = -cos(2*pi*f2*t);

%for first symbol
decision1(1)=trapz(r(1:fs*Tb).*multiplier1); %integrate
decision2(1)=trapz(r(1:fs*Tb).*multiplier2); %integrate


if(abs(decision1(1))>abs(decision2(1))) % compare
    decision(1)=1;
else
    decision(1)=0;  
end


%for rest of symbols
for(k=2:length([tsequence data])+length_data_b)  
    
decision1(k)=trapz(r(round((k-1)*fs*Tb+1):round(k*fs*Tb)).*multiplier1);
decision2(k)=trapz(r(round((k-1)*fs*Tb+1):round(k*fs*Tb)).*multiplier2);
if(abs(decision1(k))>abs(decision2(k)))
    decision(k)=1;
else
    decision(k)=0;
    
end

end

disp('errors for coherent demodulation:')
errors=sum(decision(ts_length+length_data_b+1:exp_length+ts_length+length_data_b)~=[data])





%%% end of coherent demodulator


% Non coherent demodulator -  correlator implementation


multiplier1 = cos(2*pi*f1*t);
multiplier2 = sin(2*pi*f1*t);
multiplier3 = cos(2*pi*f2*t);
multiplier4 = sin(2*pi*f2*t);

decision1(1)=trapz(r(1:fs*Tb).*multiplier1); %integrate
decision2(1)=trapz(r(1:fs*Tb).*multiplier2); %integrate
decision3(1)=trapz(r(1:fs*Tb).*multiplier3); %integrate
decision4(1)=trapz(r(1:fs*Tb).*multiplier4); %integrate

l12=decision1(1).^2+decision2(1).^2;
l22=decision3(1).^2+decision4(1).^2;

if(l12>l22)
    decision(1)=1;
else
    decision(1)=0;
end 


%for rest of symbols
for(k=2:length([tsequence data])+length_data_b)
    decision1(k)=trapz(r(round((k-1)*fs*Tb+1):round(k*fs*Tb)).*multiplier1); %integrate
    decision2(k)=trapz(r(round((k-1)*fs*Tb+1):round(k*fs*Tb)).*multiplier2); %integrate
    decision3(k)=trapz(r(round((k-1)*fs*Tb+1):round(k*fs*Tb)).*multiplier3); %integrate
    decision4(k)=trapz(r(round((k-1)*fs*Tb+1):round(k*fs*Tb)).*multiplier4); %integrate
    
    l12=decision1(k).^2+decision2(k).^2;
    l22=decision3(k).^2+decision4(k).^2;
    if(l12>l22)
        decision(k)=1;
    else
        decision(k)=0;
    end
    
end
disp('errors for non-coherent demodulation (correlator):')
errors=sum(decision(ts_length+length_data_b+1:exp_length+ts_length+length_data_b)~=[data])



wavwrite(FSK_signal, fs, 'testsound.wav');
copy_file_from_working_directory_to_sdcard( 'testsound.wav' );


%end of non-coherent correlator demodulator








